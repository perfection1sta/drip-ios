#!/usr/bin/env python3
"""
Generates Drip.xcodeproj/project.pbxproj from the existing Swift source tree.
Run from the Drip project root:  python3 generate_xcodeproj.py
"""

import os, uuid, hashlib

ROOT = os.path.dirname(os.path.abspath(__file__))
SRC  = os.path.join(ROOT, "Drip")
PROJ = os.path.join(ROOT, "Drip.xcodeproj")
os.makedirs(PROJ, exist_ok=True)

# ── Deterministic UUID from a seed string ──────────────────────────────────
def uid(seed: str) -> str:
    h = hashlib.md5(seed.encode()).hexdigest().upper()
    return h[:24]   # Xcode uses 24-char hex IDs

# ── Fixed well-known IDs ───────────────────────────────────────────────────
PROJECT_ID          = uid("PROJECT")
MAIN_GROUP_ID       = uid("MAIN_GROUP")
PRODUCTS_GROUP_ID   = uid("PRODUCTS_GROUP")
TARGET_ID           = uid("TARGET")
APP_REF_ID          = uid("APP_PRODUCT_REF")
SOURCES_PHASE_ID    = uid("SOURCES_PHASE")
RESOURCES_PHASE_ID  = uid("RESOURCES_PHASE")
FRAMEWORKS_PHASE_ID = uid("FRAMEWORKS_PHASE")
DEBUG_CONFIG_ID     = uid("DEBUG_CONFIG")
RELEASE_CONFIG_ID   = uid("RELEASE_CONFIG")
PROJECT_CFGLIST_ID  = uid("PROJECT_CFGLIST")
TARGET_DEBUG_ID     = uid("TARGET_DEBUG")
TARGET_RELEASE_ID   = uid("TARGET_RELEASE")
TARGET_CFGLIST_ID   = uid("TARGET_CFGLIST")
ASSETS_REF_ID       = uid("ASSETS_REF")
ASSETS_BUILD_ID     = uid("ASSETS_BUILD")
PLIST_REF_ID        = uid("PLIST_REF")

ASSETS_PATH  = "Drip/Resources/Assets.xcassets"
PLIST_PATH   = "Drip/Resources/Info.plist"

# ── Collect all Swift files ────────────────────────────────────────────────
swift_files = []
for dirpath, dirnames, filenames in os.walk(SRC):
    dirnames[:] = [d for d in sorted(dirnames) if d != "Assets.xcassets"]
    for f in sorted(filenames):
        if f.endswith(".swift"):
            full = os.path.join(dirpath, f)
            rel  = os.path.relpath(full, ROOT)
            swift_files.append(rel)

# Each Swift file gets a file-reference ID and a build-file ID
file_refs  = {p: uid("REF_"  + p) for p in swift_files}
build_ids  = {p: uid("BUILD_" + p) for p in swift_files}

# ── Build the folder → children mapping for PBXGroup ──────────────────────
# We'll create one PBXGroup per unique directory under Drip/
def path_components(rel_path):
    parts = []
    d = os.path.dirname(rel_path)
    while d and d != ".":
        parts.append(d)
        d = os.path.dirname(d)
    return parts

all_dirs = set()
for p in swift_files:
    d = os.path.dirname(p)
    while d and d != ".":
        all_dirs.add(d)
        d = os.path.dirname(d)

group_ids = {d: uid("GROUP_" + d) for d in all_dirs}

# children of each group
children = {d: [] for d in all_dirs}
children["_ROOT"] = []   # items directly under main group

for p in swift_files:
    d = os.path.dirname(p)
    if d in children:
        children[d].append(("file", p))
    else:
        children["_ROOT"].append(("file", p))

for d in sorted(all_dirs):
    parent = os.path.dirname(d)
    if parent in children:
        children[parent].append(("group", d))
    elif parent == "":
        children["_ROOT"].append(("group", d))

# Add Assets and Info.plist to Drip/Resources group (or _ROOT if not present)
resources_dir = "Drip/Resources"
if resources_dir in children:
    children[resources_dir].append(("assets", ASSETS_PATH))
    children[resources_dir].append(("plist",  PLIST_PATH))
else:
    children["_ROOT"].append(("assets", ASSETS_PATH))
    children["_ROOT"].append(("plist",  PLIST_PATH))

# ── Helpers ────────────────────────────────────────────────────────────────
def render_children(key):
    items = children.get(key, [])
    result = []
    for kind, val in items:
        if kind == "file":
            result.append(f"\t\t\t\t{file_refs[val]} /* {os.path.basename(val)} */,")
        elif kind == "group":
            result.append(f"\t\t\t\t{group_ids[val]} /* {os.path.basename(val)} */,")
        elif kind == "assets":
            result.append(f"\t\t\t\t{ASSETS_REF_ID} /* Assets.xcassets */,")
        elif kind == "plist":
            result.append(f"\t\t\t\t{PLIST_REF_ID} /* Info.plist */,")
    return "\n".join(result)

# ── Assemble project.pbxproj ───────────────────────────────────────────────
lines = []
def w(*args): lines.append(" ".join(str(a) for a in args))

w("// !$*UTF8*$!")
w("{")
w("\tarchiveVersion = 1;")
w("\tclasses = {")
w("\t};")
w("\tobjectVersion = 56;")
w("\tobjects = {")
w("")

# PBXBuildFile ──────────────────────────────────────────────────────────────
w("/* Begin PBXBuildFile section */")
for p in swift_files:
    w(f"\t\t{build_ids[p]} /* {os.path.basename(p)} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[p]} /* {os.path.basename(p)} */; }};")
w(f"\t\t{ASSETS_BUILD_ID} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ASSETS_REF_ID} /* Assets.xcassets */; }};")
w("/* End PBXBuildFile section */")
w("")

# PBXFileReference ──────────────────────────────────────────────────────────
w("/* Begin PBXFileReference section */")
w(f"\t\t{APP_REF_ID} /* Drip.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = Drip.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
for p in swift_files:
    name = os.path.basename(p)
    w(f"\t\t{file_refs[p]} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};")
w(f"\t\t{ASSETS_REF_ID} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = \"<group>\"; }};")
w(f"\t\t{PLIST_REF_ID} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
w("/* End PBXFileReference section */")
w("")

# PBXFrameworksBuildPhase ───────────────────────────────────────────────────
w("/* Begin PBXFrameworksBuildPhase section */")
w(f"\t\t{FRAMEWORKS_PHASE_ID} /* Frameworks */ = {{")
w(f"\t\t\tisa = PBXFrameworksBuildPhase;")
w(f"\t\t\tbuildActionMask = 2147483647;")
w(f"\t\t\tfiles = (")
w(f"\t\t\t);")
w(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w(f"\t\t}};")
w("/* End PBXFrameworksBuildPhase section */")
w("")

# PBXGroup ──────────────────────────────────────────────────────────────────
w("/* Begin PBXGroup section */")

# Main group
main_children = []
for kind, val in children.get("_ROOT", []):
    if kind == "group":
        main_children.append(f"\t\t\t\t{group_ids[val]} /* {os.path.basename(val)} */,")
    elif kind == "file":
        main_children.append(f"\t\t\t\t{file_refs[val]} /* {os.path.basename(val)} */,")

# Top-level Drip source group + Products group
drip_top = "Drip"
drip_top_id = group_ids.get(drip_top, uid("GROUP_Drip"))
group_ids[drip_top] = drip_top_id

w(f"\t\t{MAIN_GROUP_ID} = {{")
w(f"\t\t\tisa = PBXGroup;")
w(f"\t\t\tchildren = (")
w(f"\t\t\t\t{drip_top_id} /* Drip */,")
w(f"\t\t\t\t{PRODUCTS_GROUP_ID} /* Products */,")
w(f"\t\t\t);")
w(f"\t\t\tsourceTree = \"<group>\";")
w(f"\t\t}};")

# Products group
w(f"\t\t{PRODUCTS_GROUP_ID} /* Products */ = {{")
w(f"\t\t\tisa = PBXGroup;")
w(f"\t\t\tchildren = (")
w(f"\t\t\t\t{APP_REF_ID} /* Drip.app */,")
w(f"\t\t\t);")
w(f"\t\t\tname = Products;")
w(f"\t\t\tsourceTree = \"<group>\";")
w(f"\t\t}};")

# All sub-groups
for d in sorted(all_dirs):
    gid  = group_ids[d]
    name = os.path.basename(d)
    w(f"\t\t{gid} /* {name} */ = {{")
    w(f"\t\t\tisa = PBXGroup;")
    w(f"\t\t\tchildren = (")
    w(render_children(d))
    w(f"\t\t\t);")
    w(f"\t\t\tpath = {name};")
    w(f"\t\t\tsourceTree = \"<group>\";")
    w(f"\t\t}};")

w("/* End PBXGroup section */")
w("")

# PBXNativeTarget ───────────────────────────────────────────────────────────
w("/* Begin PBXNativeTarget section */")
w(f"\t\t{TARGET_ID} /* Drip */ = {{")
w(f"\t\t\tisa = PBXNativeTarget;")
w(f"\t\t\tbuildConfigurationList = {TARGET_CFGLIST_ID} /* Build configuration list for PBXNativeTarget \"Drip\" */;")
w(f"\t\t\tbuildPhases = (")
w(f"\t\t\t\t{SOURCES_PHASE_ID} /* Sources */,")
w(f"\t\t\t\t{FRAMEWORKS_PHASE_ID} /* Frameworks */,")
w(f"\t\t\t\t{RESOURCES_PHASE_ID} /* Resources */,")
w(f"\t\t\t);")
w(f"\t\t\tbuildRules = (")
w(f"\t\t\t);")
w(f"\t\t\tdependencies = (")
w(f"\t\t\t);")
w(f"\t\t\tname = Drip;")
w(f"\t\t\tpackageProductDependencies = (")
w(f"\t\t\t);")
w(f"\t\t\tproductName = Drip;")
w(f"\t\t\tproductReference = {APP_REF_ID} /* Drip.app */;")
w(f"\t\t\tproductType = \"com.apple.product-type.application\";")
w(f"\t\t}};")
w("/* End PBXNativeTarget section */")
w("")

# PBXProject ────────────────────────────────────────────────────────────────
w("/* Begin PBXProject section */")
w(f"\t\t{PROJECT_ID} /* Project object */ = {{")
w(f"\t\t\tisa = PBXProject;")
w(f"\t\t\tattributes = {{")
w(f"\t\t\t\tBuildIndependentTargetsInParallel = 1;")
w(f"\t\t\t\tLastSwiftUpdateCheck = 1500;")
w(f"\t\t\t\tLastUpgradeCheck = 1500;")
w(f"\t\t\t\tTargetAttributes = {{")
w(f"\t\t\t\t\t{TARGET_ID} = {{")
w(f"\t\t\t\t\t\tCreatedOnToolsVersion = 15.0;")
w(f"\t\t\t\t\t}};")
w(f"\t\t\t\t}};")
w(f"\t\t\t}};")
w(f"\t\t\tbuildConfigurationList = {PROJECT_CFGLIST_ID} /* Build configuration list for PBXProject \"Drip\" */;")
w(f"\t\t\tcompatibilityVersion = \"Xcode 14.0\";")
w(f"\t\t\tdevelopmentRegion = en;")
w(f"\t\t\thasScannedForEncodings = 0;")
w(f"\t\t\tknownRegions = (")
w(f"\t\t\t\ten,")
w(f"\t\t\t\tBase,")
w(f"\t\t\t);")
w(f"\t\t\tmainGroup = {MAIN_GROUP_ID};")
w(f"\t\t\tproductRefGroup = {PRODUCTS_GROUP_ID} /* Products */;")
w(f"\t\t\tprojectDirPath = \"\";")
w(f"\t\t\tprojectRoot = \"\";")
w(f"\t\t\ttargets = (")
w(f"\t\t\t\t{TARGET_ID} /* Drip */,")
w(f"\t\t\t);")
w(f"\t\t}};")
w("/* End PBXProject section */")
w("")

# PBXResourcesBuildPhase ────────────────────────────────────────────────────
w("/* Begin PBXResourcesBuildPhase section */")
w(f"\t\t{RESOURCES_PHASE_ID} /* Resources */ = {{")
w(f"\t\t\tisa = PBXResourcesBuildPhase;")
w(f"\t\t\tbuildActionMask = 2147483647;")
w(f"\t\t\tfiles = (")
w(f"\t\t\t\t{ASSETS_BUILD_ID} /* Assets.xcassets in Resources */,")
w(f"\t\t\t);")
w(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w(f"\t\t}};")
w("/* End PBXResourcesBuildPhase section */")
w("")

# PBXSourcesBuildPhase ──────────────────────────────────────────────────────
w("/* Begin PBXSourcesBuildPhase section */")
w(f"\t\t{SOURCES_PHASE_ID} /* Sources */ = {{")
w(f"\t\t\tisa = PBXSourcesBuildPhase;")
w(f"\t\t\tbuildActionMask = 2147483647;")
w(f"\t\t\tfiles = (")
for p in swift_files:
    w(f"\t\t\t\t{build_ids[p]} /* {os.path.basename(p)} in Sources */,")
w(f"\t\t\t);")
w(f"\t\t\trunOnlyForDeploymentPostprocessing = 0;")
w(f"\t\t}};")
w("/* End PBXSourcesBuildPhase section */")
w("")

# XCBuildConfiguration ──────────────────────────────────────────────────────
def build_cfg(cfg_id, name, is_debug):
    optim = "0" if is_debug else "s"
    swift_optim = "None" if is_debug else "\"Whole Module\""
    w(f"\t\t{cfg_id} /* {name} */ = {{")
    w(f"\t\t\tisa = XCBuildConfiguration;")
    w(f"\t\t\tbuildSettings = {{")
    w(f"\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;")
    w(f"\t\t\t\tCLANG_ANALYZER_NONNULL = YES;")
    w(f"\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;")
    w(f"\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\";")
    w(f"\t\t\t\tCLANG_ENABLE_MODULES = YES;")
    w(f"\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;")
    w(f"\t\t\t\tCLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;")
    w(f"\t\t\t\tCLANG_WARN_BOOL_CONVERSION = YES;")
    w(f"\t\t\t\tCLANG_WARN_COMMA = YES;")
    w(f"\t\t\t\tCLANG_WARN_CONSTANT_CONVERSION = YES;")
    w(f"\t\t\t\tCLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;")
    w(f"\t\t\t\tCLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;")
    w(f"\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;")
    w(f"\t\t\t\tCLANG_WARN_EMPTY_BODY = YES;")
    w(f"\t\t\t\tCLANG_WARN_ENUM_CONVERSION = YES;")
    w(f"\t\t\t\tCLANG_WARN_INFINITE_RECURSION = YES;")
    w(f"\t\t\t\tCLANG_WARN_INT_CONVERSION = YES;")
    w(f"\t\t\t\tCLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;")
    w(f"\t\t\t\tCLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;")
    w(f"\t\t\t\tCLANG_WARN_OBJC_LITERAL_CONVERSION = YES;")
    w(f"\t\t\t\tCLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;")
    w(f"\t\t\t\tCLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;")
    w(f"\t\t\t\tCLANG_WARN_RANGE_LOOP_ANALYSIS = YES;")
    w(f"\t\t\t\tCLANG_WARN_STRICT_PROTOTYPES = YES;")
    w(f"\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVE = YES;")
    w(f"\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;")
    w(f"\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;")
    w(f"\t\t\t\tCLANG_WARN__DUPLICATE_METHOD_MATCH = YES;")
    w(f"\t\t\t\tCOPY_PHASE_STRIP = NO;")
    dbg_fmt   = "dwarf" if is_debug else '"dwarf-with-dsym"'
    testable  = "YES" if is_debug else "NO"
    preproc   = '"DEBUG=1" $(inherited)' if is_debug else "$(inherited)"
    mtl_dbg   = "INCLUDE_SOURCE" if is_debug else "NO"
    only_arch = "YES" if is_debug else "NO"
    swift_cond = "DEBUG" if is_debug else ""
    swift_opt  = "-Onone" if is_debug else '"-Os"'
    w(f"\t\t\t\tDEBUG_INFORMATION_FORMAT = {dbg_fmt};")
    w(f"\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;")
    w(f"\t\t\t\tENABLE_TESTABILITY = {testable};")
    w(f"\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu17;")
    w(f"\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;")
    w(f"\t\t\t\tGCC_OPTIMIZATION_LEVEL = {optim};")
    w(f"\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ({preproc});")
    w(f"\t\t\t\tGCC_WARN_64_TO_32_BIT_CONVERSION = YES;")
    w(f"\t\t\t\tGCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;")
    w(f"\t\t\t\tGCC_WARN_UNDECLARED_SELECTOR = YES;")
    w(f"\t\t\t\tGCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;")
    w(f"\t\t\t\tGCC_WARN_UNUSED_FUNCTION = YES;")
    w(f"\t\t\t\tGCC_WARN_UNUSED_VARIABLE = YES;")
    w(f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
    w(f"\t\t\t\tMTL_ENABLE_DEBUG_INFO = {mtl_dbg};")
    w(f"\t\t\t\tMTL_FAST_MATH = YES;")
    w(f"\t\t\t\tONLY_ACTIVE_ARCH = {only_arch};")
    w(f"\t\t\t\tSDKROOT = iphoneos;")
    w(f"\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = {swift_cond};")
    w(f"\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = {swift_opt};")
    w(f"\t\t\t}};")
    w(f"\t\t\tname = {name};")
    w(f"\t\t}};")

def target_cfg(cfg_id, name, is_debug):
    w(f"\t\t{cfg_id} /* {name} */ = {{")
    w(f"\t\t\tisa = XCBuildConfiguration;")
    w(f"\t\t\tbuildSettings = {{")
    w(f"\t\t\t\tASSTCATALOG_COMPILER_APPICON_NAME = AppIcon;")
    w(f"\t\t\t\tASSTCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;")
    w(f"\t\t\t\tCODE_SIGN_STYLE = Automatic;")
    w(f"\t\t\t\tCURRENT_PROJECT_VERSION = 1;")
    w(f"\t\t\t\tENABLE_PREVIEWS = YES;")
    w(f"\t\t\t\tGENERATE_INFOPLIST_FILE = NO;")
    w(f"\t\t\t\tINFOPLIST_FILE = Drip/Resources/Info.plist;")
    w(f"\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 17.0;")
    w(f"\t\t\t\tLE_SWIFT_VERSION = 5.0;")
    w(f"\t\t\t\tMARKETING_VERSION = 1.0;")
    w(f"\t\t\t\tPRODUCT_BUNDLE_IDENTIFIER = com.akshaykailat.drip;")
    w(f"\t\t\t\tPRODUCT_NAME = \"$(TARGET_NAME)\";")
    w(f"\t\t\t\tSDKROOT = iphoneos;")
    w(f"\t\t\t\tSUPPORTED_PLATFORMS = \"iphoneos iphonesimulator\";")
    w(f"\t\t\t\tSWIFT_EMIT_LOC_STRINGS = YES;")
    w(f"\t\t\t\tSWIFT_VERSION = 5.0;")
    w(f"\t\t\t\tTARGETED_DEVICE_FAMILY = 1;")
    w(f"\t\t\t}};")
    w(f"\t\t\tname = {name};")
    w(f"\t\t}};")

w("/* Begin XCBuildConfiguration section */")
build_cfg(DEBUG_CONFIG_ID,   "Debug",   True)
build_cfg(RELEASE_CONFIG_ID, "Release", False)
target_cfg(TARGET_DEBUG_ID,   "Debug",   True)
target_cfg(TARGET_RELEASE_ID, "Release", False)
w("/* End XCBuildConfiguration section */")
w("")

# XCConfigurationList ───────────────────────────────────────────────────────
w("/* Begin XCConfigurationList section */")
w(f"\t\t{PROJECT_CFGLIST_ID} /* Build configuration list for PBXProject \"Drip\" */ = {{")
w(f"\t\t\tisa = XCConfigurationList;")
w(f"\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{DEBUG_CONFIG_ID} /* Debug */,")
w(f"\t\t\t\t{RELEASE_CONFIG_ID} /* Release */,")
w(f"\t\t\t);")
w(f"\t\t\tdefaultConfigurationIsVisible = 0;")
w(f"\t\t\tdefaultConfigurationName = Release;")
w(f"\t\t}};")
w(f"\t\t{TARGET_CFGLIST_ID} /* Build configuration list for PBXNativeTarget \"Drip\" */ = {{")
w(f"\t\t\tisa = XCConfigurationList;")
w(f"\t\t\tbuildConfigurations = (")
w(f"\t\t\t\t{TARGET_DEBUG_ID} /* Debug */,")
w(f"\t\t\t\t{TARGET_RELEASE_ID} /* Release */,")
w(f"\t\t\t);")
w(f"\t\t\tdefaultConfigurationIsVisible = 0;")
w(f"\t\t\tdefaultConfigurationName = Release;")
w(f"\t\t}};")
w("/* End XCConfigurationList section */")
w("")

w("\t};")
w(f"\trootObject = {PROJECT_ID} /* Project object */;")
w("}")

out_path = os.path.join(PROJ, "project.pbxproj")
with open(out_path, "w") as f:
    f.write("\n".join(lines))

print(f"✅  Generated {out_path}")
print(f"   {len(swift_files)} Swift files referenced")
