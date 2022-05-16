// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import {StringsUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";
/*
    please note this is work in progress and not ready for production just yet
*/

/**
 @title A libary for versioning of NFT content and metadata
 @dev Provides versioning for nft content and follows the semantic labeling convention.
 Each version contains an array of content and content hash pairs as well as a version label.
 Versions can be added and urls can be updated along with getters to retrieve specific versions and history.

 Include with `using Versions for Versions.set;`
 @author george baldwin
 */
library Versions {

    struct UrlWithHash {
        string url;
        bytes32 sha256hash;
    }

    struct Version {
        UrlWithHash[] urls;
        uint8[3] label;
    }

    struct Set {
        string[] labels;
        mapping(string => Version) versions;
    }

    /**
     @dev creates a new version from array of url hashe pairs and a semantic label
     @param urls An array of urls with sha-256 hash of the content on that url
     @param label a version label in a semantic style
     */
    function createVersion(
        UrlWithHash[] memory urls,
        uint8[3] memory label
    )
        internal
        pure
        returns (Version memory)
    {
        Version memory version = Version(urls, label);
        return version;
    }

    /**
     @dev adds a version to a given set by pushing the version label to an array
        and mapping the version to a string of that label. Will revert if the label already exists.
     @param set the set to add the version to
     @param version the version that will be stored
     */
    function addVersion(
        Set storage set,
        Version memory version
    ) internal {

        string memory labelKey = uintArray3ToString(version.label);

        require(
            set.versions[labelKey].urls.length == 0,
            "#Versions: A version with that label already exists"
        );

        // add to labels array
        set.labels.push(labelKey);

        // store urls and hashes in mapping
        for (uint256 i = 0; i < version.urls.length; i++){
            set.versions[labelKey].urls.push(version.urls[i]);
        }

        // store label
        set.versions[labelKey].label = version.label;
    }

    /**
     @dev gets a version from a given set. Will revert if the version doesn't exist.
     @param set The set to get the version from
     @param label The label of the requested version
     @return version The version corrosponeding to the label
     */
    function getVersion(
        Set storage set,
        uint8[3] memory label
    )
        internal
        view
        returns (Version memory)
    {
        Version memory version = set.versions[uintArray3ToString(label)];
        require(
            version.urls.length != 0,
            "#Versions: The version does not exist"
        );
        return version;
    }

    /**
     @dev updates a url of a given version in a given set
     @param set The set containing the version of which the url will be updated
     @param label The label of the requested version
     @param index The index of the url
     @param newUrl The new url to be updated to
     */
    function updateVersionURL(
        Set storage set,
        uint8[3] memory label,
        uint256 index,
        string memory newUrl
    ) internal {
        string memory labelKey = uintArray3ToString(label);
        require(
            set.versions[labelKey].urls.length != 0,
            "#Versions: The version does not exist"
        );
        require(
            set.versions[labelKey].urls.length > index,
            "#Versions: The url does not exist on that version"
        );
        set.versions[labelKey].urls[index].url = newUrl;
    }

    /**
     @dev gets all the version labels of a given set
     @param set The set containing the versions
     @return labels an array of labels as strings
    */
    function getAllLabels(
        Set storage set
    )
        internal
        view
        returns (string[] memory)
    {
        return set.labels;
    }

    /**
     @dev gets all the versions of a given set
     @param set The set containing the versions
     @return versions an array of versions
    */
    function getAllVersions(
        Set storage set
    )
        internal
        view
        returns (Version[] memory)
    {
        return getVersionsFromLabels(set, set.labels);
    }

    /**
     @dev gets the versions of a given array of labels as strings, reverts if no labels are given
     @param set The set containing the versions
     @return versions an array of versions
    */
    function getVersionsFromLabels(
        Set storage set,
        string[] memory _labels
    )
        internal
        view
        returns (Version[] memory)
    {
        require(_labels.length != 0, "#Versions: No labels provided");
        Version[] memory versionArray = new Version[](_labels.length);

        for (uint256 i = 0; i < _labels.length; i++) {
                versionArray[i] = set.versions[_labels[i]];
        }

        return versionArray;
    }

    /**
     @dev gets the last added version of a given set, reverts if no versions are in the set
     @param set The set containing the versions
     @return version the last added version
    */
    function getLatestVersion(
        Set storage set
    )
        internal
        view
        returns (Version memory)
    {
        require(
            set.labels.length != 0,
            "#Versions: No versions exist"
        );
        return set.versions[
            set.labels[set.labels.length - 1]
        ];
    }

    /**
     @dev A helper function to convert a three length array of numbers into a semantic style verison label
     @param label the label as a uint8[3] array
     @return label the label as a string
    */
    function uintArray3ToString (uint8[3] memory label)
        internal
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(
            StringsUpgradeable.toString(label[0]),
            ".",
            StringsUpgradeable.toString(label[1]),
            ".",
            StringsUpgradeable.toString(label[2])
        ));
    }
}