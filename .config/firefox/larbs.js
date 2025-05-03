// These are changes made on top of the Arkenfox JS file to tweak it as
// desired. Any of these settings can be overridden by the user.

// Disable the Twitter/R*ddit/Faceberg ads in the URL bar:
defaultPref("browser.urlbar.quicksuggest.enabled", false);
defaultPref("browser.urlbar.suggest.topsites", false); // [FF78+]

// Do not suggest web history in the URL bar:
defaultPref("browser.urlbar.suggest.history", false);

// Do not prefil forms:
defaultPref("signon.prefillForms", false);

// Do not autocomplete in the URL bar:
defaultPref("browser.urlbar.autoFill", false);

// Enable the addition of search keywords:
defaultPref("keyword.enabled", true);

// Allow access to http (i.e. not https) sites:
defaultPref("dom.security.https_only_mode", false);

// Keep cookies until expiration or user deletion:
defaultPref("network.cookie.lifetimePolicy", 0);

defaultPref("dom.webnotifications.serviceworker.enabled", false);

// Disable push notifications:
defaultPref("dom.push.enabled", false);

// Disable the pocket antifeature:
defaultPref("extensions.pocket.enabled", false);

// Don't autodelete cookies on shutdown:
defaultPref("privacy.clearOnShutdown.cookies", false);

// Enable custom userChrome.js:
defaultPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

// This could otherwise cause some issues on bank logins and other annoying sites:
defaultPref("network.http.referer.XOriginPolicy", 0);

// Disable Firefox sync and its menu entries
defaultPref("identity.fxaccounts.enabled", false);

// Fix the issue where right mouse button instantly clicks
defaultPref("ui.context_menus.after_mouseup", true);

// i want muh heckin dark moderino
defaultPref("privacy.resistFingerprinting", false);

// shit is slow without it sometimes
defaultPref("webgl.disabled", false);
