 Feature 1: Centralized App Strings

 New file: lib/utils/app_strings.dart

 abstract final class AppStrings {
   // App-level
   static const appTitle = 'Jai Ram Status Maker';
   static const appBarTitle = 'Jai Ram';

   // Premium / upgrade
   static const getPremium = 'Get Premium';
   static const goPremium = 'Go Premium';
   static const unlockExclusiveFeatures = 'Unlock all exclusive features:';
   static const premiumFeatureTemplates = 'All Premium Templates';
   static const premiumFeatureNoAds = 'No Ads (Future)';
   static const premiumFeatureHighRes = 'High-Res Export';
   static const maybeLater = 'Maybe Later';
   static const upgradeNow = 'Upgrade Now';
   static const upgradeSuccessDemo = 'Premium unlocked! (Demo mode)';

   // Home screen
   static const noQuotesInCategory = 'No quotes in this category';
   static const selectDesign = 'Select Design';
   static const seeAll = 'See All';
   static const noTemplatesForCategory = 'No templates for this category';

   // Editor screen
   static const editStatus = 'Edit Status';
   static const shareFunctionalityComingSoon = 'Share functionality coming soon!';
   static const textSize = 'Text Size';
   static const backgroundColor = 'Background Color';

   // Quote list
   static const quoteAuthorPrefix = '- ';

   // Bottom action row
   static const failedToCaptureImage = 'Failed to capture image.';
   static const posterFileName = 'jai_bhim_poster.png';
   static const preparingImageForDownload = 'Preparing image for download...';
   static const downloadInitiated = 'Download initiated! Check your downloads.';
   static const imageSavedToPrefix = 'Image saved to: ';
   static const ok = 'OK';
   static const preparingImageForSharing = 'Preparing image for sharing...';
   static const sharingNotSupportedWeb = 'Sharing is not supported on the web yet.';
   static const shareText = 'Check out this Jai Ram status!';
   static const shareLabel = 'Share';
   static const downloadLabel = 'Download';
   static const cannotShareWeb = 'Cannot share: Download initiated on web.';
   static const failedToGenerateImagePrefix = 'Failed to generate image: ';

   // Profile editor
   static const errorPickingImagePrefix = 'Error picking image: ';
   static const profileCustomization = 'Profile Customization';
   static const userNameLabel = 'User Name';
   static const subtitleLabel = 'Subtitle';

   // Welcome screen
   static const welcomeLoginWithPhone = 'Login with Phone';
   static const welcomeContinueAsGuest = 'Continue as Guest';
   static const welcomeAuthComingSoon = 'Authentication coming soon!';
   static const welcomeTagline = 'Share the wisdom of Dr. B.R. Ambedkar';

   // Drawer
   static const drawerNavHome = 'Home';
   static const drawerNavQuotesLibrary = 'Quotes Library';
   static const drawerNavAbout = 'About';
   static const drawerNavSettings = 'Settings';
   static const drawerUpgradeSection = 'Upgrade to Premium';
   static const drawerSettingsComingSoon = 'Settings coming soon!';
   static const drawerPremiumActive = 'Premium Active';
   static const aboutDescription = 'A poster maker app inspired by Dr. B.R. Ambedkar\'s teachings.';
 }

 Files to modify (replace inline strings with AppStrings.xxx):

 - lib/main.dart — title
 - lib/widgets/home_app_bar.dart — 'Jai Ram', 'Get Premium'
 - lib/screens/home_screen.dart — all dialog strings + empty state strings
 - lib/screens/editor_screen.dart — 4 strings
 - lib/screens/quote_list_screen.dart — '- ' prefix
 - lib/widgets/bottom_action_row.dart — ~10 strings
 - lib/widgets/poster_preview.dart — '- ' prefix
 - lib/widgets/profile_editor.dart — 4 strings
 