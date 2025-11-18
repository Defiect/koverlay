#pragma once
#include <QQuickView>

struct wl_surface;
struct wl_compositor;
class OverlayConfig;

class OverlayView : public QQuickView {
    Q_OBJECT
public:
    explicit OverlayView(OverlayConfig *cfg, QWindow *parent=nullptr);

    // screen selector 0..N-1
    void selectScreenByIndex(int idx);

    // Method callable from QML to store selected text
    Q_INVOKABLE void setSelectedText(const QString &text);

public slots:
    void toggle();
    void showOverlay();
    void hideOverlay();
    void toggleCopyMode();

signals:
    void clearSelection();

private:
    void applyEmptyInputRegion();
    void applyFullInputRegion();
    void copySelectionToClipboard();

    OverlayConfig *cfg_;
    QString selectedText_;
};
