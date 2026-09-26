# Gan Ainm: from this folder to TestFlight

Everything happens on your MacBook. Allow about an hour the first time. After that, a new build takes ten minutes.

## Before you start

- **Xcode** is installed (free, from the Mac App Store).
- Your **Apple Developer Program** membership is active.
- Xcode knows your account: **Xcode > Settings > Accounts**. If your Apple ID is not listed, press **+** and sign in.

## 1. Get the app onto the Mac

1. On GitHub, open the branch `claude/nathan-companion-app-k1105h`, then the folder `NathanCompanion/ios`.
2. Download `GanAinm.swiftpm.zip` and double-click it. You now have a folder called `GanAinm.swiftpm`.

## 2. Run it once on the Mac

1. Open Xcode. Choose **File > Open**, pick the `GanAinm.swiftpm` folder and press **Open**.
2. At the top of the window, click the device name and choose an iPhone from the list (for example, iPhone 17).
3. Press the **Run** triangle. The first build takes a few minutes.
4. If red errors appear, copy the error text and paste it to Claude. The app was written without a Mac to hand, so one or two small fixes are likely.

## 3. Sign it with your account

1. In the left-hand list, click the top item, **Gan Ainm**.
2. Find **Signing & Capabilities** (or **Signing**). Under **Team**, choose your name.
3. The bundle identifier is `ie.stpaulsbessbrook.gaeilge`. Leave it as it is.

## 4. Create the app in App Store Connect

1. Go to appstoreconnect.apple.com and sign in.
2. **Apps > + > New App.**
3. Platform: **iOS**. Name: **Gan Ainm** (if the name is taken, try **Gan Ainm Gaeilge**; the name can be changed later, the bundle ID cannot). Primary language: **English (UK)**. Bundle ID: choose `ie.stpaulsbessbrook.gaeilge`. SKU: `ganainm-001`. User access: **Full Access**.
4. If the bundle ID is not in the list, go back to Xcode, run the app once on your own iPhone (plug it in and choose it as the device), then try again. Xcode registers the ID for you.

## 5. Upload a build

1. In Xcode, set the device at the top to **Any iOS Device (arm64)**.
2. **Product > Archive.** Wait for the Organizer window.
3. Select the new archive and press **Distribute App**, then **TestFlight & App Store** (or **App Store Connect**), then **Distribute**.

If Archive is greyed out or fails, open the same folder in the **Swift Playgrounds** app on the Mac and use its **Upload to App Store Connect** button instead.

## 6. Send it to testers

1. In App Store Connect, open the app and the **TestFlight** tab. The build shows as *Processing* for 10 to 30 minutes.
2. When asked about **export compliance**, choose **None of the algorithms mentioned above**. The app uses no encryption.
3. **Internal testers** (quickest, no review). First invite your colleague into App Store Connect: **Users and Access > +**, enter their name and school email, tick the **Developer** role (or **Marketing**, which is enough to test), and send. They accept the email invitation. Then, back in the app's **TestFlight** tab, under **Internal Testing** press **+**, name a group (for example *Staff*), and add yourself and the colleague. Up to 100 people.
4. **External testers** (anyone with an email address): needs Apple's beta review, usually about a day. **Wait for ABAIR's written consent before this step**, because it distributes Áine's voice beyond your own devices.
5. Each tester installs the free **TestFlight** app, opens the invitation email and taps **Install**.

## 7. Collect feedback

Testers take a screenshot inside the app and TestFlight offers to send it with a comment. Feedback appears in App Store Connect under **TestFlight > Feedback**.

## Each new version

Before archiving, open `Package.swift` and raise `bundleVersion` by one (`"1"` becomes `"2"`). App Store Connect refuses a build number it has seen before.

## Pupils as testers

Year 8 pupils are 11 or 12. Check the school's safeguarding and data protection position before inviting pupils, since TestFlight needs each tester's Apple ID email. Starting with staff as internal testers avoids the question for the first round.
