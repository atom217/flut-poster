 Feature 7: Add Photo of Self

 Part A – Android permissions

 Modify android/app/src/main/AndroidManifest.xml (add before <application>):
 <uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
 <uses-permission android:name="android.permission.CAMERA"/>
 <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
     android:maxSdkVersion="32"/>

 Part B – Shared photo picker utility

 Add to lib/services/providers.dart (or a new lib/utils/photo_utils.dart):

 Future<void> pickAndSetProfilePhoto(WidgetRef ref, BuildContext context) async {
   final picker = ImagePicker();
   try {
     final XFile? image = await picker.pickImage(source: ImageSource.gallery);
     if (image != null) {
       ref.read(userProfileProvider.notifier).update(
         (state) => state.copyWith(photoUrl: image.path),
       );
     }
   } catch (e) {
     if (context.mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('${AppStrings.errorPickingImagePrefix}$e')),
       );
     }
   }
 }

 Modify lib/widgets/profile_editor.dart: Replace _pickImage() body with call to pickAndSetProfilePhoto(ref, context).

 The AppDrawer (Feature 3) already calls pickAndSetProfilePhoto from the tappable avatar in DrawerHeader.
