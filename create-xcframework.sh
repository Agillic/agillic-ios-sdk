#set framework folder name
PROJECT_NAME=AgillicSDK
PROJECT_DIR="."
FRAMEWORK_FOLDER_NAME="${PROJECT_NAME}_XCFramework"
# set framework name or read it from project by this variable
FRAMEWORK_NAME="${PROJECT_NAME}"
#xcframework path
FRAMEWORK_PATH="${PROJECT_DIR}/build/${FRAMEWORK_FOLDER_NAME}/${FRAMEWORK_NAME}.xcframework"
# set path for iOS simulator archive
SIMULATOR_ARCHIVE_PATH="${PROJECT_DIR}/build/${FRAMEWORK_FOLDER_NAME}/simulator.xcarchive"
# set path for iOS device archive
IOS_DEVICE_ARCHIVE_PATH="${PROJECT_DIR}/build/${FRAMEWORK_FOLDER_NAME}/iOS.xcarchive"
rm -rf "${FRAMEWORK_PATH}"
echo "Deleted ${FRAMEWORK_PATH}"
mkdir "${FRAMEWORK_PATH}"
echo "Created ${FRAMEWORK_PATH}"
echo "Archiving ${FRAMEWORK_NAME}"
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS Simulator" -archivePath "${SIMULATOR_ARCHIVE_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
xcodebuild archive -scheme ${FRAMEWORK_NAME} -destination="iOS" -archivePath "${IOS_DEVICE_ARCHIVE_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
#Creating XCFramework
xcodebuild -create-xcframework -framework ${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -framework ${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${FRAMEWORK_NAME}.framework -output "${FRAMEWORK_PATH}"
rm -rf "${SIMULATOR_ARCHIVE_PATH}"
rm -rf "${IOS_DEVICE_ARCHIVE_PATH}"
open "${FRAMEWORK_PATH}/.."
