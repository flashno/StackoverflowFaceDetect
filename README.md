# Stack Overflow Face Detection App
## Features

- Fetches top 10 Stack Overflow users by reputation
- Downloads and caches user profile images
- Performs on-device face detection using CoreImage
- Detects facial features including:
  - Presence of smile
  - Eye state (open/closed)
  - Face angle
- Modern SwiftUI interface with detail views
- Concurrent image processing with controlled parallelism
- Comprehensive error handling and loading states

## Requirements

- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

## Installation

1. Clone the repository:
```bash
git clone https://github.com/flashno/StackoverflowFaceDetect.git
cd StackoverflowFaceDetect
```

2. Open the project in Xcode:
```bash
open StackoverflowFaceDetect.xcodeproj
```

3. Build and run the project (⌘R)

No additional setup or third-party dependencies are required as the project uses native iOS frameworks.


## Completed in 3 Hours (I took breaks in between working on it, as I didn't have a 3 hour chunk to finish the whole thing)

- Core API integration
- Basic face detection
- User interface implementation
- Error handling
- Image caching
- Concurrent processing
- Loading states

## Future Improvements

- Add tests (unit and UI)
- Add offline support
- Implement pull-to-refresh
- Add search/filter capabilities
- Add dark mode support
- Improve face detection accuracy
- Add CI/CD pipeline

