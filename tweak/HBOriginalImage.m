// HBOriginalImage.m
// 小黑盒 (com.max.xiaoheihe) 自动查看原图 tweak
// 目标: iOS 16.3.1 / TrollStore (injected dylib)

#import <objc/runtime.h>
#import <objc/message.h>
#import <dispatch/dispatch.h>
#import <time.h>
#import <stdint.h>

typedef signed char HBChar;
typedef _Bool HBBool;

extern void NSLog(id format, ...);

static IMP gOrigSetHidden = NULL;
static IMP gOrigSetBytes  = NULL;
static IMP gOrigUpdate    = NULL;

static uintptr_t gLastButton = 0;
static uint64_t  gLastTapMs  = 0;

static uint64_t hbNowMs(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (uint64_t)ts.tv_sec * 1000ULL + (uint64_t)(ts.tv_nsec / 1000000ULL);
}

static inline id hbMsg0(id obj, const char *sel) {
    return ((id (*)(id, SEL))objc_msgSend)(obj, sel_registerName(sel));
}

static inline HBBool hbHidden(id obj) {
    return ((HBBool (*)(id, SEL))objc_msgSend)(obj, sel_registerName("isHidden"));
}

static void hbTapNow(id button) {
    if (!button) return;
    if (hbHidden(button)) return;
    if (!hbMsg0(button, "window")) return;

    uintptr_t p = (uintptr_t)button;
    uint64_t now = hbNowMs();
    if (p == gLastButton && now - gLastTapMs < 800) return;
    gLastButton = p;
    gLastTapMs = now;

    // UIControlEventTouchUpInside == 1 << 6 == 64
    ((void (*)(id, SEL, unsigned long))objc_msgSend)(
        button, sel_registerName("sendActionsForControlEvents:"), 64UL);
    NSLog(@"[HBOriginalImage] auto tapped CheckOriginalImageButton (%p)", button);
}

static void hbRetry(id button, int attempt) {
    if (attempt >= 10) return;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (!button) return;
        if (hbHidden(button) || !hbMsg0(button, "window")) {
            hbRetry(button, attempt + 1);
            return;
        }
        hbTapNow(button);
    });
}

static void hbScheduleTap(id button, int attempt) {
    (void)attempt;
    hbRetry(button, 0);
}

static void hbSetHidden(id self, SEL _cmd, HBBool hidden) {
    ((void (*)(id, SEL, HBBool))gOrigSetHidden)(self, _cmd, hidden);
    if (!hidden) hbScheduleTap(self, 0);
}

static void hbSetOriginImageBytesSize(id self, SEL _cmd, id size) {
    ((void (*)(id, SEL, id))gOrigSetBytes)(self, _cmd, size);
    if (!hbHidden(self)) hbScheduleTap(self, 0);
}

static void hbUpdateCheckButton(id self, SEL _cmd) {
    ((void (*)(id, SEL))gOrigUpdate)(self, _cmd);
    id btn = hbMsg0(self, "checkOriginalImageButton");
    if (btn) hbScheduleTap(btn, 0);
}

static BOOL hbInstall(void) {
    Class btnCls = objc_getClass("CheckOriginalImageButton");
    if (btnCls) {
        SEL sel = sel_registerName("setHidden:");
        Method m = class_getInstanceMethod(btnCls, sel);
        if (m) {
            gOrigSetHidden = method_getImplementation(m);
            const char *types = method_getTypeEncoding(m);
            if (!class_addMethod(btnCls, sel, (IMP)hbSetHidden, types)) {
                method_setImplementation(m, (IMP)hbSetHidden);
            }
            NSLog(@"[HBOriginalImage] hooked -[CheckOriginalImageButton setHidden:]");
        }
        SEL sel2 = sel_registerName("setOriginImageBytesSize:");
        Method m2 = class_getInstanceMethod(btnCls, sel2);
        if (m2) {
            gOrigSetBytes = method_getImplementation(m2);
            method_setImplementation(m2, (IMP)hbSetOriginImageBytesSize);
            NSLog(@"[HBOriginalImage] hooked -[CheckOriginalImageButton setOriginImageBytesSize:]");
        }
    }

    Class groupCls = objc_getClass("HBPhotoGroupView");
    if (groupCls) {
        SEL sel3 = sel_registerName("updateCheckOriginalImageButtonForCurrentPageIfNeeded");
        Method m3 = class_getInstanceMethod(groupCls, sel3);
        if (m3) {
            gOrigUpdate = method_getImplementation(m3);
            method_setImplementation(m3, (IMP)hbUpdateCheckButton);
            NSLog(@"[HBOriginalImage] hooked -[HBPhotoGroupView updateCheckOriginalImageButtonForCurrentPageIfNeeded]");
        }
    }

    return (btnCls != nil);
}

static void hbRetryInstall(int tries) {
    if (hbInstall()) {
        NSLog(@"[HBOriginalImage] installed (attempt %d)", tries);
        return;
    }
    if (tries >= 40) {
        NSLog(@"[HBOriginalImage] CheckOriginalImageButton not found, giving up");
        return;
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        hbRetryInstall(tries + 1);
    });
}

__attribute__((constructor))
static void hb_init(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        hbRetryInstall(1);
    });
}
