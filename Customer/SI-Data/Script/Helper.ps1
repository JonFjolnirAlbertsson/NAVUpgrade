﻿$MergeResult = Merge-NAVUpgradeObjects `
    -OriginalObjects $OriginalObjects `
    -TargetObjects $TargetObjects `
    -WorkingFolder $WorkingFolder `
    -CreateDeltas `
    -VersionListPrefixes $VersionListPrefixes `
    -Force