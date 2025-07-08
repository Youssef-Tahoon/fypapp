# Zakaty App

A Flutter application for managing Zakat calculations and community support cases.

## Features

- **Zakat Calculator**: Calculate Zakat eligibility based on various assets
- **Community Cases**: Submit and browse through community support cases
- **PDF Document Support**: Upload and view PDF proof documents for cases
- **Admin Dashboard**: Manage cases and review submitted documents

## PDF Document Handling

The app handles PDF documents as follows:

1. **Uploading**: Users can upload PDF files as proof documents when submitting cases
2. **Storage**: PDFs are stored directly in the database as Base64 strings
3. **Viewing**: Both users and admins can view uploaded PDF documents
4. **Admin Access**: Admins have additional privileges to download PDF documents

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Configure Firebase (Firestore) for your project
4. Run the app with `flutter run`
>>>>>>> 9d3431672be28728f76a45773f4e3b71cd693b58
