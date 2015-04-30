#!/bin/sh
set -e

mkdir -p "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

RESOURCES_TO_COPY=${PODS_ROOT}/resources-to-copy-${TARGETNAME}.txt
> "$RESOURCES_TO_COPY"

install_resource()
{
  case $1 in
    *.storyboard)
      echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .storyboard`.storyboardc" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.xib)
        echo "ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile ${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib ${PODS_ROOT}/$1 --sdk ${SDKROOT}"
      ibtool --reference-external-strings-file --errors --warnings --notices --output-format human-readable-text --compile "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename \"$1\" .xib`.nib" "${PODS_ROOT}/$1" --sdk "${SDKROOT}"
      ;;
    *.framework)
      echo "mkdir -p ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      mkdir -p "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      echo "rsync -av ${PODS_ROOT}/$1 ${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      rsync -av "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${FRAMEWORKS_FOLDER_PATH}"
      ;;
    *.xcdatamodel)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1"`.mom\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodel`.mom"
      ;;
    *.xcdatamodeld)
      echo "xcrun momc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd\""
      xcrun momc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcdatamodeld`.momd"
      ;;
    *.xcmappingmodel)
      echo "xcrun mapc \"${PODS_ROOT}/$1\" \"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm\""
      xcrun mapc "${PODS_ROOT}/$1" "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/`basename "$1" .xcmappingmodel`.cdm"
      ;;
    *.xcassets)
      ;;
    /*)
      echo "$1"
      echo "$1" >> "$RESOURCES_TO_COPY"
      ;;
    *)
      echo "${PODS_ROOT}/$1"
      echo "${PODS_ROOT}/$1" >> "$RESOURCES_TO_COPY"
      ;;
  esac
}
          install_resource "../LYService/LYService/core data/PublicLibrary.xcdatamodeld"
                    install_resource "../OWkit/OWKit/table/refresh_row.png"
                    install_resource "../OWkit/OWKit/collection view/OWCollectionFooterLoadingMoreView.xib"
                    install_resource "../OWkit/OWKit/collection view/OWCollectionHeaderView.xib"
                    install_resource "../OWkit/OWKit/message/OWSlideMessageViewController.xib"
                    install_resource "../OWkit/OWKit/navigation/OWSubNavigationController.xib"
                    install_resource "../OWkit/OWKit/refresh view/LYRefreshView.xib"
                    install_resource "../OWkit/OWKit/refresh view/LYRefreshView2.xib"
                    install_resource "../OWkit/OWKit/table/TableLoadMoreView.xib"
                    install_resource "../OWReader/OWReader/reader/AudioViewController/AudioViewController.xib"
                    install_resource "../OWReader/OWReader/reader/book mark/BookmarkController.xib"
                    install_resource "../OWReader/OWReader/reader/book mark/BookmarkTableCellCell.xib"
                    install_resource "../OWReader/OWReader/reader/book mark/BookmarkTableController.xib"
                    install_resource "../OWReader/OWReader/reader/BookDigest/BookDigestTableController.xib"
                    install_resource "../OWReader/OWReader/reader/BookDigest/BookDigestTableViewCell.xib"
                    install_resource "../OWReader/OWReader/reader/catalogue/CatalogueTableCell.xib"
                    install_resource "../OWReader/OWReader/reader/catalogue/CatalogueTableController.xib"
                    install_resource "../OWReader/OWReader/reader/catalogue/CatalogueViewController.xib"
                    install_resource "../OWReader/OWReader/reader/common/GLAsyncMessageController.xib"
                    install_resource "../OWReader/OWReader/reader/JRBookDigestController/DigestManagementViewController.xib"
                    install_resource "../OWReader/OWReader/reader/JRBookNotesController/NotesViewController.xib"
                    install_resource "../OWReader/OWReader/reader/page/LYBookNavigationBarController.xib"
                    install_resource "../OWReader/OWReader/reader/page/PageViewController.xib"
                    install_resource "../OWReader/OWReader/reader/root/LYFontSizeControllerViewController.xib"
                    install_resource "../OWReader/OWReader/reader/SearchViewController/SearchCell.xib"
                    install_resource "../OWReader/OWReader/reader/SearchViewController/SearchHeader.xib"
                    install_resource "../OWReader/OWReader/reader/SearchViewController/SearchViewController.xib"
                    install_resource "../OWReader/OWReader/reader/slider/GLSliderBubbleController.xib"
                    install_resource "../OWReader/OWReader/reader/slider/LYBookSliderController.xib"
                    install_resource "../OWReader/OWReader/reader/VideoController/VideoViewController.xib"
                    install_resource "../OWReader/OWReader/core data/LogicBook.xcdatamodeld"
          
rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [[ "${ACTION}" == "install" ]]; then
  rsync -avr --copy-links --no-relative --exclude '*/.svn/*' --files-from="$RESOURCES_TO_COPY" / "${INSTALL_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
rm -f "$RESOURCES_TO_COPY"

if [[ -n "${WRAPPER_EXTENSION}" ]] && [ "`xcrun --find actool`" ] && [ `find . -name '*.xcassets' | wc -l` -ne 0 ]
then
  case "${TARGETED_DEVICE_FAMILY}" in
    1,2)
      TARGET_DEVICE_ARGS="--target-device ipad --target-device iphone"
      ;;
    1)
      TARGET_DEVICE_ARGS="--target-device iphone"
      ;;
    2)
      TARGET_DEVICE_ARGS="--target-device ipad"
      ;;
    *)
      TARGET_DEVICE_ARGS="--target-device mac"
      ;;
  esac
  find "${PWD}" -name "*.xcassets" -print0 | xargs -0 actool --output-format human-readable-text --notices --warnings --platform "${PLATFORM_NAME}" --minimum-deployment-target "${IPHONEOS_DEPLOYMENT_TARGET}" ${TARGET_DEVICE_ARGS} --compress-pngs --compile "${BUILT_PRODUCTS_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
fi
