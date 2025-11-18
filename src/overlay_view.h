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

public slots:
    void toggle();
    void showOverlay();
    void hideOverlay();
    void toggleCopyMode();
    void showCopyMode();
    void hideCopyMode();

public:
    Q_INVOKABLE void updateSelection(const QString &selection);

protected:
    bool event(QEvent *event) override;

private:
    void applyEmptyInputRegion();
    void applyFullInputRegion();
    void copySelectionToClipboard();

    OverlayConfig *cfg_;
    bool copyMode_ = false;
    QString pendingSelection_;
};
