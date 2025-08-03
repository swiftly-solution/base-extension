add_rules("mode.debug", "mode.release")

includes("@builtin/xpack")
includes("core.base.option")
includes("platform.os")

local SDK_PATH = os.getenv("HL2SDK")
local MM_PATH = os.getenv("MMSOURCE")
local GITHUB_SHA = os.getenv("GITHUB_SHA") or "Local"
local VERSION = os.getenv("VERSION") or "Local"
local PROJECT_NAME = "baseext.ext"

function GetDistDirName()
    if is_plat("windows") then
        return "win64"
    else
        return "linuxsteamrt64"
    end
end

target(PROJECT_NAME)
    set_kind("shared")
    set_optimize("fastest")
    set_strip("none")

    add_files("build/proto/**.cc")

    --[[ Vendor Section ]]

    add_files("vendor/swiftly-ext/**.cpp")
    add_files("vendor/embedder/src/**.cpp", { cxxflags = "-rdynamic -g1" })

    --[[ Embedder Section ]]

    before_build(function(target)
        import("core.base.json")

        function GetDistDirName()
            if is_plat("windows") then
                return "windows"
            else
                return "linux"
            end
        end

        local config_path = path.join(os.scriptdir(), "vendor/embedder/libs/links.json")
        local config_data = json.loadfile(config_path)

        for i=1,#config_data.includes do
            target:add("includedirs", "vendor/embedder/libs/"..config_data.includes[i])
        end

        local libs = config_data.libraries[GetDistDirName()]
        for i=1,#libs do
            target:add("links", "vendor/embedder/libs/"..libs[i])
        end
    end)

    --[[ Plugin Section ]]

    add_files({
        'src/entrypoint.cpp',

        SDK_PATH.."/tier1/keyvalues3.cpp",
        SDK_PATH.."/entity2/entitysystem.cpp",
        SDK_PATH.."/entity2/entityidentity.cpp",
        SDK_PATH.."/tier1/convar.cpp",
        SDK_PATH.."/entity2/entitykeyvalues.cpp",
    }, { cxxflags = "-rdynamic -g1" })

    --[[ Protobuf Section ]]

    on_load(function(target)
        local protoc = is_plat("windows") and SDK_PATH.."/devtools/bin/protoc.exe" or SDK_PATH.."/devtools/bin/linux/protoc" 
        local args = "--proto_path="..SDK_PATH.."/thirdparty/protobuf-3.21.8/src --proto_path=./protobufs --proto_path="..SDK_PATH.."/public --proto_path="..SDK_PATH.."/public/engine --proto_path="..SDK_PATH.."/public/mathlib --proto_path="..SDK_PATH.."/public/vstdlib --proto_path="..SDK_PATH.."/public/tier0 --proto_path="..SDK_PATH.."/public/tier1 --proto_path="..SDK_PATH.."/public/entity2 --proto_path="..SDK_PATH.."/public/game/server --proto_path="..SDK_PATH.."/game/shared --proto_path="..SDK_PATH.."/game/server --proto_path="..SDK_PATH.."/common --cpp_out=build/proto"

        function mysplit (inputstr, sep)
            if sep == nil then sep = "%s" end
            local t={}
            for str in string.gmatch(inputstr, "([^"..sep.."]+)") do table.insert(t, str) end
            return t
        end
    
        if os.exists("build/proto") then
            os.rmdir("build/proto")
        end
        os.mkdir("build/proto")

        for _, sourcefile in ipairs(os.files("./protobufs/*.proto")) do
            local splitted = mysplit(sourcefile, "/")
            local filename = splitted[#splitted]

            os.iorun(protoc .. " "..args.." --dependency_out=build/proto/"..filename..".d "..sourcefile)
        end
    end)

    --[[ Flags Section ]]

    add_cxxflags("gcc::-Wno-invalid-offsetof")
    add_cxxflags("gcc::-Wno-return-local-addr")
    add_cxxflags("gcc::-Wno-overloaded-virtual")
    add_cxxflags("gcc::-Wno-unknown-pragmas")
    add_cxxflags("gcc::-Wno-non-virtual-dtor")
    add_cxxflags("gcc::-Wno-attributes")
    add_cxxflags("gcc::-Wno-array-bounds")
    add_cxxflags("gcc::-Wno-int-to-pointer-cast")
    add_cxxflags("gcc::-Wno-sign-compare")
    add_cxxflags("gcc::-Wno-write-strings")
    add_cxxflags("gcc::-Wno-class-memaccess")
    add_cxxflags("gcc::-fexceptions")
    add_cxxflags("gcc::-fPIC")
    
    add_cflags("gcc::-Wno-return-local-addr")
    add_cflags("gcc::-Wno-unknown-pragmas")
    add_cflags("gcc::-Wno-attributes")
    add_cflags("gcc::-Wno-array-bounds")
    add_cflags("gcc::-Wno-int-to-pointer-cast")
    add_cflags("gcc::-Wno-sign-compare")
    add_cflags("gcc::-Wno-write-strings")
    add_cflags("gcc::-fexceptions")
    add_cflags("gcc::-fPIC")
    add_cflags("gcc::-pipe")
    add_cflags("gcc::-fno-strict-aliasing")
    add_cflags("gcc::-Wall")
    add_cflags("gcc::-Wno-uninitialized")
    add_cflags("gcc::-Wno-unused")
    add_cflags("gcc::-Wno-switch")
    add_cflags("gcc::-msse")
    add_cflags("gcc::-fvisibility=hidden")
    add_cflags("gcc::-mfpmath=sse")
    add_cflags("gcc::-fno-omit-frame-pointer")
    add_cflags("gcc::-fvisibility-inlines-hidden")
    add_cflags("gcc::-fno-exceptions")
    add_cflags("gcc::-fno-threadsafe-statics")
    add_cflags("gcc::-Wno-register")
    add_cflags("gcc::-Wno-delete-non-virtual-dtor")

    add_cxxflags("cl::/Zc:__cplusplus")
    add_cxxflags("cl::/Ox")
    add_cxxflags("cl::/Zo")
    add_cxxflags("cl::/Oy-")
    add_cxxflags("cl::/Z7")
    add_cxxflags("cl::/TP")
    add_cxxflags("cl::/MT")
    add_cxxflags("cl::/W3")
    add_cxxflags("cl::/Z7")
    add_cxxflags("cl::/EHsc")
    add_cxxflags("cl::/IGNORE:4101,4267,4244,4005,4003,4530")

    --[[ HL2SDK Mandatory Libs ]]
    if is_plat("windows") then
        add_links({
            SDK_PATH.."/lib/public/win64/tier0.lib",
            SDK_PATH.."/lib/public/win64/tier1.lib",
            SDK_PATH.."/lib/public/win64/interfaces.lib",
            SDK_PATH.."/lib/public/win64/mathlib.lib",
            SDK_PATH.."/lib/public/win64/2015/libprotobuf.lib",
        })
    else
        add_links({
            SDK_PATH.."/lib/linux64/libtier0.so",
            SDK_PATH.."/lib/linux64/tier1.a",
            SDK_PATH.."/lib/linux64/interfaces.a",
            SDK_PATH.."/lib/linux64/mathlib.a",
            SDK_PATH.."/lib/linux64/release/libprotobuf.a",
        })
    end

    --[[ Includes Section ]]

    add_includedirs({
        SDK_PATH,
        SDK_PATH.."/public",
        SDK_PATH.."/public/entity2",
        SDK_PATH.."/game/server",
        SDK_PATH.."/thirdparty/protobuf-3.21.8/src",
        SDK_PATH.."/common",
        SDK_PATH.."/game/shared",
        SDK_PATH.."/public/engine",
        SDK_PATH.."/public/mathlib",
        SDK_PATH.."/public/tier0",
        SDK_PATH.."/public/tier1",
        SDK_PATH.."/public/game/server",
        SDK_PATH.."/public/mathlib",
        MM_PATH.."/core",
        MM_PATH.."/core/sourcehook"
    })

    add_includedirs({
        "vendor",
        "vendor/embedder/src",
        "vendor/swiftly-ext/hooks",
        "vendor/swiftly-ext/hooks/dynohook",
        "src",
        "build/proto",
        SDK_PATH
    })

    --[[ Defines Section ]]

    if(is_plat("windows")) then
        add_defines({
            "COMPILER_MSVC",
            "COMPILER_MSVC64",
            "WIN32",
            "WINDOWS",
            "CRT_SECURE_NO_WARNINGS",
            "CRT_SECURE_NO_DEPRECATE",
            "CRT_NONSTDC_NO_DEPRECATE",
            "_MBCS",
            "META_IS_SOURCE2",
            "COMPILER_MSVC",
            "COMPILER_MSVC64",
            "WIN32",
            "_WIN32",
            "WINDOWS",
            "_WINDOWS",
            "CRT_SECURE_NO_WARNINGS",
            "_CRT_SECURE_NO_WARNINGS",
            "CRT_SECURE_NO_DEPRECATE",
            "_CRT_SECURE_NO_DEPRECATE",
            "CRT_NONSTDC_NO_DEPRECATE",
            "_CRT_NONSTDC_NO_DEPRECATE",
            "_MBCS",
            "META_IS_SOURCE2",
            "X64BITS",
            "PLATFORM_64BITS",
            "NDEBUG",
        })
    else
        add_defines({
            "_LINUX",
            "LINUX",
            "POSIX",
            "GNUC",
            "COMPILER_GCC",
            "PLATFORM_64BITS",
            "META_IS_SOURCE2",
            "_GLIBCXX_USE_CXX11_ABI=0",

            "_vsnprintf=vsnprintf",
            "_alloca=alloca",
            "strcmpi=strcasecmp",
            "strnicmp=strncasecmp",
            "_snprintf=snprintf",
            "_stricmp=strcasecmp",
            "_strnicmp=strncasecmp",
            "stricmp=strcasecmp",
        })
    end

    add_defines({
        "GITHUB_SHA=\""..GITHUB_SHA.."\"",
        "VERSION=\""..VERSION.."\"",
        "HAVE_STRUCT_TIMESPEC",
    })

    --[[ Vendor Libraries ]]

    if is_plat("windows") then
        add_links({
            "psapi",
            "winmm",
            "ws2_32",
            "wldap32",
            "advapi32",
            "kernel32",
            "comdlg32",
            "crypt32",
            "normaliz",
            "wsock32",
            "legacy_stdio_definitions",
            "legacy_stdio_wide_specifiers",
            "user32",
            "gdi32",
            "winspool",
            "shell32",
            "ole32",
            "oleaut32",
            "uuid",
            "odbc32",
            "odbccp32",
            "msvcrt",
            "dbghelp",
            SDK_PATH.."/lib/public/win64/steam_api64.lib"
        })
    else
        add_links({
            "gnutls",
            "z",
            "pthread",
            "ssl",
            "crypto",
            "m",
            "dl",
            "readline",
            "rt",
            "idn2",
            "psl",
            "brotlidec",
            "backtrace",
            "stdc++",

            SDK_PATH.."/lib/linux64/libsteam_api.so"
        })
    end

    --[[ Misc Section ]]

    set_languages("cxx17")

    after_build(function(target)
        function GetDistDirName()
            if is_plat("windows") then
                return "win64"
            else
                return "linuxsteamrt64"
            end
        end

        if os.exists("build/package") then
            os.rmdir("build/package")
        end

        if os.exists("plugin_files") then
            os.cp("plugin_files/", 'build/package/addons/swiftly')
        end
        os.mkdir('build/package/addons/swiftly/extensions/'..GetDistDirName())
        os.cp(target:targetfile(), 'build/package/addons/swiftly/extensions/'..GetDistDirName().."/"..PROJECT_NAME.."."..(is_plat("windows") and "dll" or "so"))
    end)