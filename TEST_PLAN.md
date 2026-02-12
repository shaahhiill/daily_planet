# Daily Planet News App - Test Plan

**Tester:** Shaahil Seedin
**Date:** February 11, 2026  
**App Version:** 1.0.0  
**Platform:** Android (Flutter)  
**Test Device:** OnePlus BE2029 (Android 11)

---

## 1. Test Scope

This test plan covers functional, UI/UX, and device compatibility testing for the Daily Planet news application.

---

## 2. Test Categories

### 2.1 Authentication Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-01: User Registration | 1. Open app<br>2. Tap "Sign Up"<br>3. Enter valid email/password<br>4. Tap "Sign Up" | User account created, navigates to home screen | ✅ PASS | Firebase auth successful |
| TC-02: Login with Valid Credentials | 1. Enter registered email<br>2. Enter correct password<br>3. Tap "Login" | User authenticated, navigates to home screen | ✅ PASS | Auth state persists |
| TC-03: Login with Invalid Credentials | 1. Enter invalid email/password<br>2. Tap "Login" | Error message displayed, stays on login screen | ✅ PASS | Shows Firebase error |
| TC-04: Password Mismatch | 1. On register screen<br>2. Enter different passwords in confirm field<br>3. Tap "Sign Up" | Shows "Passwords do not match" error | ✅ PASS | Validation works |
| TC-05: Empty Fields | 1. Leave email or password empty<br>2. Tap "Login" | Firebase error shown | ✅ PASS | Handled by Firebase |

---

### 2.2 Navigation Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-06: Bottom Navigation (Portrait) | Tap each bottom nav icon (Home, Explore, Saved, Search) | Navigates to correct screen | ✅ PASS | Smooth transitions |
| TC-07: Side Navigation (Landscape) | Rotate device, tap each side nav item | Navigates to correct screen | ✅ PASS | Layout changes correctly |
| TC-08: Article Navigation | Tap an article card | Opens article detail screen | ✅ PASS | Master/detail pattern works |
| TC-09: Category Navigation | Tap a category on Explore screen | Opens category-specific news | ✅ PASS | Filters correctly |
| TC-10: Back Navigation | Press back button on any screen | Returns to previous screen | ✅ PASS | Navigation stack works |

---

### 2.3 Content Display Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-11: Home Screen Layout | Open home screen | First article full-size, rest horizontal cards | ✅ PASS | Layout correct |
| TC-12: Article Images | Scroll through news feed | All images load correctly | ✅ PASS | Caching works |
| TC-13: Missing Images | View articles without images | Placeholder icon shown | ✅ PASS | Error handling works |
| TC-14: Article Time Display | View any article | Shows relative time (e.g., "2h ago") | ✅ PASS | Time formatting correct |
| TC-15: Source Labels | View articles | Source name shown in red | ✅ PASS | Styling correct |

---

### 2.4 Feature Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-16: Save Article | 1. Open article<br>2. Tap bookmark icon | Article saved, icon changes to filled | ✅ PASS | Persists in storage |
| TC-17: Unsave Article | 1. Tap filled bookmark icon | Article removed from saved | ✅ PASS | Updates immediately |
| TC-18: View Saved Articles | Navigate to Saved screen | All saved articles displayed | ✅ PASS | Local storage works |
| TC-19: Search Functionality | 1. Go to Search<br>2. Enter "technology"<br>3. Tap search | Relevant articles displayed | ✅ PASS | API search works |
| TC-20: Pull to Refresh | Pull down on home screen | Spinner shows, snackbar confirms refresh | ✅ PASS | API call successful |

---

### 2.5 Device Capabilities Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-21: Theme Toggle | Tap sun/moon icon in header | App switches between light/dark mode | ✅ PASS | Theme persists |
| TC-22: Offline Detection | Turn off WiFi/mobile data | Red banner appears at top | ✅ PASS | Shows offline message |
| TC-23: Online Detection | Turn WiFi back on | Red banner disappears | ✅ PASS | Real-time detection |
| TC-24: Social Share - WhatsApp | Tap WhatsApp icon on article | Opens WhatsApp with article link | ✅ PASS | Deep linking works |
| TC-25: Social Share - Instagram | Tap Instagram icon | Opens Instagram app | ✅ PASS | App opens |
| TC-26: Social Share - Twitter | Tap Twitter icon | Opens Twitter with pre-filled tweet | ✅ PASS | Share intent works |
| TC-27: Social Share - LinkedIn | Tap LinkedIn icon | Opens LinkedIn share dialog | ✅ PASS | Web share works |
| TC-28: Swipe Navigation (Right) | Swipe right on article detail | Shows previous article | ✅ PASS | Gesture works |
| TC-29: Swipe Navigation (Left) | Swipe left on article detail | Shows next article | ✅ PASS | Updates UI |
| TC-30: Swipe at Boundaries | Swipe at first/last article | Shows snackbar message | ✅ PASS | Handles edge cases |

---

### 2.6 Responsive Design Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-31: Portrait Orientation | Use app in portrait mode | Bottom navigation, vertical scroll | ✅ PASS | Default layout |
| TC-32: Landscape Orientation | Rotate device to landscape | Side navigation, horizontal layout | ✅ PASS | Adaptive layout |
| TC-33: Orientation Switch | Switch between portrait/landscape multiple times | No crashes, smooth transitions | ✅ PASS | State preserved |
| TC-34: Different Screen Sizes | Test on different screen sizes | Content scales appropriately | ✅ PASS | Responsive |

---

### 2.7 Profile & Logout Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-35: Open Profile Sheet | Tap profile icon in header | Bottom sheet opens with email | ✅ PASS | Shows user info |
| TC-36: Logout Confirmation | 1. Tap logout<br>2. Tap "Logout" in dialog | Returns to login screen | ✅ PASS | Auth state cleared |
| TC-37: Cancel Logout | 1. Tap logout<br>2. Tap "Cancel" | Stays on current screen | ✅ PASS | Dialog closes |

---

### 2.8 UI/UX Testing

| Test Case | Steps | Expected Result | Status | Notes |
|-----------|-------|-----------------|--------|-------|
| TC-38: Material Design Compliance | Review all screens | Follows Material Design guidelines | ✅ PASS | Proper elevation, shadows |
| TC-39: Color Accessibility | Check contrast in light/dark modes | All text readable | ✅ PASS | WCAG compliant |
| TC-40: Touch Targets | Tap all interactive elements | All at least 48x48dp | ✅ PASS | Accessibility standards |
| TC-41: Loading States | Trigger API calls | Shows loading indicators | ✅ PASS | User feedback present |
| TC-42: Error States | Trigger errors (no internet) | Clear error messages shown | ✅ PASS | User-friendly errors |

---

## 3. Test Summary

**Total Test Cases:** 42  
**Passed:** 42 ✅  
**Failed:** 0 ❌  
**Pass Rate:** 100%

---

## 4. Known Issues

None identified during testing.

---

## 5. Testing Environment

- **Device:** OnePlus BE2029
- **OS:** Android 11 (API Level 30)
- **Flutter Version:** 3.24.5
- **Dart Version:** 3.5.4
- **Test Date:** February 11, 2026
- **Network:** WiFi + Mobile Data tested

---

## 6. Conclusion

All functionality tested successfully. The app demonstrates:
- Robust authentication flow
- Smooth navigation
- Proper state management
- Device capability integration
- Responsive design
- Material Design compliance
- Error handling

The application is ready for production deployment.
