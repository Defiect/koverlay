#include "overlay_view.h"
#include "overlay_config.h"

#include <QQmlContext>
#include <QScreen>
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QDebug>
#include <QClipboard>
#include <QGuiApplication>
#include <QEvent>

#include <wayland-client.h>
#include <LayerShellQt/Window>

OverlayView::OverlayView(OverlayConfig *cfg, QWindow *parent)
: QQuickView(parent), cfg_(cfg)
{
    setColor(Qt::transparent);
    setFlags(Qt::FramelessWindowHint);
    setFlag(Qt::WindowTransparentForInput, true);
    setResizeMode(QQuickView::SizeRootObjectToView);

    // expose config to QML
    rootContext()->setContextProperty(QStringLiteral("cfg"), cfg_);
    rootContext()->setContextProperty(QStringLiteral("overlayView"), this);

    // layer-shell setup
    auto *ls = LayerShellQt::Window::get(this);
    ls->setLayer(LayerShellQt::Window::LayerOverlay); // or LayerTop if needed
    ls->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
    ls->setExclusiveZone(0);

    setSource(QUrl(QStringLiteral("qrc:/koverlay/Overlay.qml")));
    setResizeMode(QQuickView::SizeViewToRootObject);
    if (status() == QQuickView::Error) {
        for (const auto &e : errors()) qWarning() << e.toString();
    }

    connect(this, &QWindow::visibleChanged, this, [this](bool v){
        if (!v) return;
        if (auto *ls = LayerShellQt::Window::get(this))
            ls->setLayer(LayerShellQt::Window::LayerOverlay);
        if (!copyMode_) {
            applyEmptyInputRegion();
        }
    });
}

void OverlayView::selectScreenByIndex(int idx) {
    const auto screens = QGuiApplication::screens();
    if (idx >= 0 && idx < screens.size()) setScreen(screens[idx]);
    else if (auto *prim = QGuiApplication::primaryScreen()) setScreen(prim);
}

void OverlayView::toggle() { setVisible(!isVisible()); }

void OverlayView::showOverlay() {
    // Do NOT make the window fullscreen or set it to screen geometry here.
    // LayerShell will position the content-sized window according to anchors/margins.
    show();
    raise();
    requestActivate();
    applyEmptyInputRegion();
}


void OverlayView::hideOverlay() { hide(); }

void OverlayView::toggleCopyMode() {
    if (copyMode_) {
        hideCopyMode();
    } else {
        showCopyMode();
    }
}

void OverlayView::showCopyMode() {
    copyMode_ = true;
    pendingSelection_.clear();
    
    // Enable input for copy mode
    setFlag(Qt::WindowTransparentForInput, false);
    
    // Enable keyboard interactivity for text selection
    if (auto *ls = LayerShellQt::Window::get(this)) {
        ls->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityOnDemand);
    }
    
    applyFullInputRegion();
    
    // Switch QML to copy mode view
    rootContext()->setContextProperty(QStringLiteral("copyMode"), true);
    setSource(QUrl(QStringLiteral("qrc:/koverlay/CopyModeOverlay.qml")));
    
    show();
    raise();
    requestActivate();
    
    qInfo() << "koverlay: copy mode activated";
}

void OverlayView::hideCopyMode() {
    // Copy any pending selection before hiding
    if (!pendingSelection_.isEmpty()) {
        copySelectionToClipboard();
    }
    
    copyMode_ = false;
    pendingSelection_.clear();
    
    // Disable input and keyboard interactivity
    setFlag(Qt::WindowTransparentForInput, true);
    
    if (auto *ls = LayerShellQt::Window::get(this)) {
        ls->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
    }
    
    // Switch back to normal overlay view
    rootContext()->setContextProperty(QStringLiteral("copyMode"), false);
    setSource(QUrl(QStringLiteral("qrc:/koverlay/Overlay.qml")));
    
    hide();
    
    qInfo() << "koverlay: copy mode deactivated";
}

bool OverlayView::event(QEvent *event) {
    // Handle focus out events in copy mode
    if (copyMode_ && event->type() == QEvent::FocusOut) {
        qInfo() << "koverlay: focus lost, copying selection to clipboard";
        if (!pendingSelection_.isEmpty()) {
            copySelectionToClipboard();
        }
    }
    
    return QQuickView::event(event);
}

void OverlayView::applyFullInputRegion() {
    auto *pni = QGuiApplication::platformNativeInterface();
    auto *wlSurf = static_cast<wl_surface*>(pni->nativeResourceForWindow("surface", this));
    if (!wlSurf) return;
    
    // Set input region to full surface (default behavior)
    wl_surface_set_input_region(wlSurf, nullptr);
}

void OverlayView::copySelectionToClipboard() {
    if (pendingSelection_.isEmpty()) {
        return;
    }
    
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(pendingSelection_, QClipboard::Clipboard);
    
    qInfo() << "koverlay: copied" << pendingSelection_.length() << "characters to clipboard";
    pendingSelection_.clear();
}

void OverlayView::updateSelection(const QString &selection) {
    pendingSelection_ = selection;
}

void OverlayView::applyEmptyInputRegion() {
    auto *pni = QGuiApplication::platformNativeInterface();
    auto *wlSurf = static_cast<wl_surface*>(pni->nativeResourceForWindow("surface", this));
    auto *wlComp = static_cast<wl_compositor*>(pni->nativeResourceForIntegration("compositor"));
    if (!wlSurf || !wlComp) return;
    wl_region *empty = wl_compositor_create_region(wlComp);
    wl_surface_set_input_region(wlSurf, empty);
    wl_region_destroy(empty);
}
