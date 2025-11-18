#include "overlay_view.h"
#include "overlay_config.h"

#include <QQmlContext>
#include <QScreen>
#include <QtGui/qpa/qplatformnativeinterface.h>
#include <QDebug>
#include <QClipboard>
#include <QGuiApplication>

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
        applyEmptyInputRegion();
    });

    // Connect to activeChanged signal to detect focus loss
    connect(this, &QWindow::activeChanged, this, [this](){
        if (!isActive() && cfg_->copyMode()) {
            // Window lost focus while in copy mode - copy selection to clipboard
            copySelectionToClipboard();
        }
    });
}

void OverlayView::selectScreenByIndex(int idx) {
    const auto screens = QGuiApplication::screens();
    if (idx >= 0 && idx < screens.size()) setScreen(screens[idx]);
    else if (auto *prim = QGuiApplication::primaryScreen()) setScreen(prim);
}

void OverlayView::setSelectedText(const QString &text) {
    selectedText_ = text;
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

void OverlayView::applyEmptyInputRegion() {
    auto *pni = QGuiApplication::platformNativeInterface();
    auto *wlSurf = static_cast<wl_surface*>(pni->nativeResourceForWindow("surface", this));
    auto *wlComp = static_cast<wl_compositor*>(pni->nativeResourceForIntegration("compositor"));
    if (!wlSurf || !wlComp) return;
    wl_region *empty = wl_compositor_create_region(wlComp);
    wl_surface_set_input_region(wlSurf, empty);
    wl_region_destroy(empty);
}

void OverlayView::applyFullInputRegion() {
    auto *pni = QGuiApplication::platformNativeInterface();
    auto *wlSurf = static_cast<wl_surface*>(pni->nativeResourceForWindow("surface", this));
    if (!wlSurf) return;
    // Setting null input region means the whole surface receives input
    wl_surface_set_input_region(wlSurf, nullptr);
}

void OverlayView::toggleCopyMode() {
    bool newMode = !cfg_->copyMode();
    cfg_->setCopyMode(newMode);

    if (newMode) {
        // Enable input interaction for copy mode
        setFlag(Qt::WindowTransparentForInput, false);
        applyFullInputRegion();
        // Enable keyboard interactivity
        if (auto *ls = LayerShellQt::Window::get(this)) {
            ls->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityOnDemand);
        }
        show();
        raise();
        requestActivate();
    } else {
        // Disable input interaction - return to transparent mode
        setFlag(Qt::WindowTransparentForInput, true);
        applyEmptyInputRegion();
        // Disable keyboard interactivity
        if (auto *ls = LayerShellQt::Window::get(this)) {
            ls->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
        }
    }
}

void OverlayView::copySelectionToClipboard() {
    if (selectedText_.isEmpty()) return;
    QClipboard *clipboard = QGuiApplication::clipboard();
    clipboard->setText(selectedText_);
    selectedText_.clear();
    // Signal QML to clear the visible selection
    emit clearSelection();
}
