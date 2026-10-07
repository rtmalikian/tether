#!/usr/bin/env python3
"""Generate Tether.xcodeproj/project.pbxproj from the source tree.

Run from the repo root:  python3 generate_project.py
"""
import os
import uuid

ROOT = os.path.dirname(os.path.abspath(__file__))

SOURCES = [
    "Tether/TetherApp.swift",
    "Tether/Models.swift",
    "Tether/Persistence.swift",
    "Tether/Notifications.swift",
    "Tether/BreakEngine.swift",
    "Tether/PomodoroEngine.swift",
    "Tether/UsageMonitor.swift",
    "Tether/BuddyManager.swift",
    "Tether/FeedbackStore.swift",
    "Tether/BreakOverlay.swift",
    "Tether/Views/MenuBarView.swift",
    "Tether/Views/DashboardView.swift",
    "Tether/Views/PomodoroView.swift",
    "Tether/Views/BuddyView.swift",
    "Tether/Views/ErgonomicsView.swift",
    "Tether/Views/SettingsView.swift",
]

INFO_PLIST = "Tether/Info.plist"


def uid():
    return uuid.uuid4().hex[:24].upper()


def main():
    for f in SOURCES + [INFO_PLIST]:
        assert os.path.exists(os.path.join(ROOT, f)), f"missing source: {f}"

    build_files = {s: uid() for s in SOURCES}
    file_refs = {s: uid() for s in SOURCES}
    plist_ref = uid()
    product_ref = uid()
    main_group = uid()
    tether_group = uid()
    views_group = uid()
    products_group = uid()
    sources_phase = uid()
    frameworks_phase = uid()
    resources_phase = uid()
    target = uid()
    project = uid()
    cfg_list_project = uid()
    cfg_list_target = uid()
    cfg_proj_debug = uid()
    cfg_proj_release = uid()
    cfg_tgt_debug = uid()
    cfg_tgt_release = uid()

    def build_file_section():
        lines = []
        for s in SOURCES:
            lines.append(
                f"\t\t{build_files[s]} = {{isa = PBXBuildFile; fileRef = {file_refs[s]}; }};")
        return "\n".join(lines)

    def file_ref_section():
        lines = []
        for s in SOURCES:
            name = os.path.basename(s)
            lines.append(
                f"\t\t{file_refs[s]} = {{isa = PBXFileReference; "
                f"lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};")
        lines.append(
            f"\t\t{plist_ref} = {{isa = PBXFileReference; "
            f"lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = \"<group>\"; }};")
        lines.append(
            f"\t\t{product_ref} = {{isa = PBXFileReference; "
            f"explicitFileType = wrapper.application; includeInIndex = 0; "
            f"path = Tether.app; sourceTree = BUILT_PRODUCTS_DIR; }};")
        return "\n".join(lines)

    def group_section():
        view_refs = ", ".join(file_refs[s] for s in SOURCES if "/Views/" in s)
        top_refs = ", ".join(file_refs[s] for s in SOURCES if "/Views/" not in s)
        return (
            f"\t\t{main_group} = {{isa = PBXGroup; children = ({tether_group}, {products_group}); "
            f"sourceTree = \"<group>\"; }};\n"
            f"\t\t{tether_group} = {{isa = PBXGroup; children = ({top_refs}, {views_group}, {plist_ref}); "
            f"path = Tether; sourceTree = \"<group>\"; }};\n"
            f"\t\t{views_group} = {{isa = PBXGroup; children = ({view_refs}); "
            f"path = Views; sourceTree = \"<group>\"; }};\n"
            f"\t\t{products_group} = {{isa = PBXGroup; children = ({product_ref}); "
            f"name = Products; sourceTree = \"<group>\"; }};"
        )

    def target_section():
        return (
            f"\t\t{target} = {{isa = PBXNativeTarget; "
            f"buildConfigurationList = {cfg_list_target}; "
            f"buildPhases = ({sources_phase}, {frameworks_phase}, {resources_phase}); "
            f"buildRules = (); dependencies = (); name = Tether; "
            f"productName = Tether; productReference = {product_ref}; "
            f"productType = \"com.apple.product-type.application\"; }};"
        )

    def project_section():
        return (
            f"\t\t{project} = {{isa = PBXProject; "
            f"attributes = {{LastUpgradeCheck = 1500; "
            f"TargetAttributes = {{{target} = {{CreatedOnToolsVersion = 15.0;}};}};}}; "
            f"buildConfigurationList = {cfg_list_project}; "
            f"compatibilityVersion = \"Xcode 14.0\"; "
            f"developmentRegion = en; hasScannedForEncodings = 0; "
            f"knownRegions = (en); mainGroup = {main_group}; "
            f"productRefGroup = {products_group}; projectDirPath = \"\"; "
            f"projectRoot = \"\"; targets = ({target}); }};"
        )

    def phases_section():
        src_files = ", ".join(build_files[s] for s in SOURCES)
        return (
            f"\t\t{sources_phase} = {{isa = PBXSourcesBuildPhase; "
            f"buildActionMask = 2147483647; files = ({src_files}); runOnlyForDeploymentPostprocessing = 0; }};\n"
            f"\t\t{frameworks_phase} = {{isa = PBXFrameworksBuildPhase; "
            f"buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};\n"
            f"\t\t{resources_phase} = {{isa = PBXResourcesBuildPhase; "
            f"buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};"
        )

    def cfg(cfg_id, name, settings):
        body = "\n".join(f"\t\t\t\t{kv};" for kv in settings)
        return (f"\t\t{cfg_id} = {{isa = XCBuildConfiguration; "
                f"buildSettings = {{\n{body}\n\t\t\t}}; name = {name}; }};")

    project_settings = [
        "ALWAYS_SEARCH_USER_PATHS = NO",
        "CLANG_ANALYZER_NONNULL = YES",
        "CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE",
        "CLANG_CXX_LANGUAGE_STANDARD = \"gnu++20\"",
        "CLANG_ENABLE_MODULES = YES",
        "CLANG_ENABLE_OBJC_ARC = YES",
        "COPY_PHASE_STRIP = NO",
        "GCC_C_LANGUAGE_STANDARD = gnu17",
        "MTL_FAST_MATH = YES",
    ]

    def target_settings(debug):
        s = [
            "ALWAYS_SEARCH_USER_PATHS = NO",
            "CLANG_ANALYZER_NONNULL = YES",
            "CODE_SIGN_STYLE = Automatic",
            "COMBINE_HIDPI_IMAGES = YES",
            "CURRENT_PROJECT_VERSION = 1",
            "ENABLE_HARDENED_RUNTIME = YES",
            "GENERATE_INFOPLIST_FILE = NO",
            "INFOPLIST_FILE = Tether/Info.plist",
            "LD_RUNPATH_SEARCH_PATHS = (\"@executable_path/../Frameworks\")",
            "MACOSX_DEPLOYMENT_TARGET = 13.0",
            "MARKETING_VERSION = 1.0.0",
            "PRODUCT_BUNDLE_IDENTIFIER = com.rtmalikian.tether",
            "PRODUCT_NAME = \"$(TARGET_NAME)\"",
            "SWIFT_EMIT_LOC_STRINGS = YES",
            "SWIFT_VERSION = 5.0",
        ]
        if debug:
            s += [
                "DEBUG_INFORMATION_FORMAT = dwarf",
                "ENABLE_TESTABILITY = YES",
                "GCC_OPTIMIZATION_LEVEL = 0",
                "ONLY_ACTIVE_ARCH = YES",
                "SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG",
                "SWIFT_OPTIMIZATION_LEVEL = \"-Onone\"",
            ]
        else:
            s += [
                "DEBUG_INFORMATION_FORMAT = \"dwarf-with-dsym\"",
                "SWIFT_OPTIMIZATION_LEVEL = \"-O\"",
            ]
        return s

    def cfg_list(list_id, cfg_ids):
        cfgs = ", ".join(cfg_ids)
        return (f"\t\t{list_id} = {{isa = XCConfigurationList; "
                f"buildConfigurations = ({cfgs}); "
                f"defaultConfigurationIsVisible = 0; "
                f"defaultConfigurationName = Release; }};")

    pbxproj = """{
\tarchiveVersion = 1;
\tclasses = {
\t};
\tobjectVersion = 56;
\tobjects = {

/* Begin PBXBuildFile section */
%s
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
%s
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
%s
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
%s
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
%s
/* End PBXNativeTarget section */

/* Begin PBXProject section */
%s
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
/* (empty resources phase declared in phases section) */
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
/* (sources phase declared in phases section) */
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
%s
%s
%s
%s
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
%s
%s
/* End XCConfigurationList section */
\t};
\trootObject = %s;
}
""" % (
        build_file_section(),
        file_ref_section(),
        f"\t\t{frameworks_phase} = {{isa = PBXFrameworksBuildPhase; buildActionMask = 2147483647; files = (); runOnlyForDeploymentPostprocessing = 0; }};",
        group_section(),
        target_section(),
        project_section(),
        cfg(cfg_proj_debug, "Debug", project_settings),
        cfg(cfg_proj_release, "Release", project_settings),
        cfg(cfg_tgt_debug, "Debug", target_settings(True)),
        cfg(cfg_tgt_release, "Release", target_settings(False)),
        cfg_list(cfg_list_project, [cfg_proj_debug, cfg_proj_release]),
        cfg_list(cfg_list_target, [cfg_tgt_debug, cfg_tgt_release]),
        project,
    )

    # The phases section declares sources + resources; insert before XCBuildConfiguration.
    pbxproj = pbxproj.replace(
        "/* Begin PBXSourcesBuildPhase section */\n/* (sources phase declared in phases section) */\n/* End PBXSourcesBuildPhase section */",
        "/* Begin PBXSourcesBuildPhase section */\n" + phases_section() + "\n/* End PBXSourcesBuildPhase section */",
    )
    # Remove the now-redundant empty resources comment block.
    pbxproj = pbxproj.replace(
        "/* Begin PBXResourcesBuildPhase section */\n/* (empty resources phase declared in phases section) */\n/* End PBXResourcesBuildPhase section */\n\n",
        "",
    )

    out_dir = os.path.join(ROOT, "Tether.xcodeproj")
    os.makedirs(out_dir, exist_ok=True)
    with open(os.path.join(out_dir, "project.pbxproj"), "w") as f:
        f.write(pbxproj)
    print("wrote Tether.xcodeproj/project.pbxproj")


if __name__ == "__main__":
    main()
