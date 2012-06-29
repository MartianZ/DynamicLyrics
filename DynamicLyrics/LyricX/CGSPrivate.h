//
//  CoreGraphicsServices.h
//
#ifndef CORE_GRAPHICS_SERVICES_H
#define CORE_GRAPHICS_SERVICES_H
#include <Carbon/Carbon.h> /* for ProcessSerialNumber */

typedef int CGSWindow; /* Note that CGS can retrieve a particular window's CGSConnection automatically, given a CGSWindow, but many functions do not do this - unless explicitly stated, all CGSConnection arguments must be provided and valid */
typedef int CGSConnection;
typedef void* CGSValue;
typedef void* CGSRegion;
typedef void* CGSBoundingShape;
typedef void* CGSAnimationRef; /* Ref really is a pointer to some other structure.  *ref + 40 = window ID */

typedef enum _CGSTransitionType {
    CGSNone = 0,    // No transition effect.
    CGSFade,        // Cross-fade.
    CGSZoom,        // Zoom/fade towards us.
    CGSReveal,      // Reveal new desktop under old.
    CGSSlide,       // Slide old out and new in.
    CGSWarpFade,    // Warp old and fade out revealing new.
    CGSSwap,        // Swap desktops over graphically.
    CGSCube,        // The well-known cube effect.
    CGSWarpSwitch,   // Warp old, switch and un-warp.
    CGSFlip			// Very smooth flip over effect like Dashboard.
} CGSTransitionType;

typedef enum _CGSTransitionOption {
    CGSDown,                // Old desktop moves down.
    CGSLeft,                // Old desktop moves left.
    CGSRight,               // Old desktop moves right.
    CGSInRight,             // CGSSwap: Old desktop moves into screen,
	//                      new comes from right.
    CGSBottomLeft = 5,      // CGSSwap: Old desktop moves to bl,
	//                      new comes from tr.
    CGSBottomRight,         // Old desktop to br, New from tl.
    CGSDownTopRight,        // CGSSwap: Old desktop moves down, new from tr.
    CGSUp,                  // Old desktop moves up.
    CGSTopLeft,             // Old desktop moves tl.
    
    CGSTopRight,            // CGSSwap: old to tr. new from bl.
    CGSUpBottomRight,       // CGSSwap: old desktop up, new from br.
    CGSInBottom,            // CGSSwap: old in, new from bottom.
    CGSLeftBottomRight,     // CGSSwap: old one moves left, new from br.
    CGSRightBottomLeft,     // CGSSwap: old one moves right, new from bl.
    CGSInBottomRight,       // CGSSwap: onl one in, new from br.
    CGSInOut                // CGSSwap: old in, new out.
} CGSTransitionOption;

typedef struct _CGSTransitionSpec {
    uint32_t unknown1;
    CGSTransitionType type;
    CGSTransitionOption option;
    CGSWindow wid; /* Can be 0 for full-screen */
    float *backColour; /* Null for black otherwise pointer to 3 float array with RGB value */
} CGSTransitionSpec;

#define kCGSNullConnectionID ((CGSConnection)0)
    CGSConnection _CGSDefaultConnection(void);

 OSStatus CGSNewConnection(void *something /* can be NULL, parent connection? */, CGSConnection *outID);
OSStatus CGSReleaseConnection(const CGSConnection cid);
 void CGSInitialize();

OSStatus CGSNewTransition(const CGSConnection cid, const CGSTransitionSpec* spec, int *pTransitionHandle);
 OSStatus CGSInvokeTransition(const CGSConnection cid, int transitionHandle, float duration);
 OSStatus CGSReleaseTransition(const CGSConnection cid, int transitionHandle);
 OSStatus CGSCreateGenieWindowAnimation(const CGSConnection cid, const CGSWindow wid1, const CGSWindow wid2, CGSAnimationRef *ref /* Guessed */);

 void /* Maybe returns OSStatus? */ GenieAnimationRelease(CGSAnimationRef ref); /* Self-explanatory */

 OSStatus CGSSetWindowAnimationProgress(CGSAnimationRef ref, float progress /* Guessed.  Suspect value between 0.0 and 1.0 */);

 OSStatus CGSReleaseWindowAnimation(CGSAnimationRef ref);

#endif