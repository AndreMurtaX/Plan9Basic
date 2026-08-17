# Plan9Basic - PlatformInfoLib Documentation

## Platform Information Library Reference Manual

**Version:** 1.0  
**Date:** January 2026

---

## Table of Contents

1. [Overview](#overview)
2. [Version Information](#version-information)
3. [Architecture Information](#architecture-information)
4. [Version Checking](#version-checking)
5. [Service Pack Information](#service-pack-information)
6. [Complete Examples](#complete-examples)
7. [Quick Reference](#quick-reference)

---

## Overview

The PlatformInfoLib library provides functions to retrieve information about the operating system on which your Plan9Basic program is running. This is useful for:

- Displaying system information to users
- Checking OS compatibility before using platform-specific features
- Logging environment details for debugging
- Adapting program behavior based on the platform

### Multi-Platform Support

Plan9Basic runs on multiple platforms through the FireMonkey framework:

| Platform | Example Values |
|----------|----------------|
| **Windows** | "Windows 10 (Version 10.0, Build 19045, 64-bit Edition)" |
| **macOS** | "macOS 13.0 (Ventura)" |
| **iOS** | "iOS 16.0" |
| **Android** | "Android 13.0" |
| **Linux** | "Linux x86_64" |

---

## Version Information

### os_platform$()

Returns a complete, human-readable string describing the operating system.

**Syntax:**
```basic
platformInfo$ = os_platform$()
```

**Returns:** String with full OS description including version, build, and edition

**Example:**
```basic
println "Platform: "; os_platform$()
' Windows output: "Windows 10 (Version 10.0, Build 19045, 64-bit Edition)"
' macOS output: "macOS 13.0"
' Android output: "Android 13.0"
```

---

### os_name$()

Returns the simple name of the operating system.

**Syntax:**
```basic
osName$ = os_name$()
```

**Returns:** String with the OS name (e.g., "Windows", "macOS", "iOS", "Android", "Linux")

**Example:**
```basic
println "Operating System: "; os_name$()
' Output: "Windows" or "macOS" or "Android", etc.
```

---

### os_major()

Returns the major version number of the operating system.

**Syntax:**
```basic
majorVersion = os_major()
```

**Returns:** Numeric major version

**Example:**
```basic
println "Major version: "; os_major()
' Windows 10: 10
' Windows 11: 10 (Note: Windows 11 reports as 10.0 with high build number)
' macOS Ventura: 13
' Android 13: 13
```

---

### os_minor()

Returns the minor version number of the operating system.

**Syntax:**
```basic
minorVersion = os_minor()
```

**Returns:** Numeric minor version

**Example:**
```basic
println "Minor version: "; os_minor()
' Windows 10/11: 0
' macOS 13.4: 4
```

---

### os_build()

Returns the build number of the operating system.

**Syntax:**
```basic
buildNumber = os_build()
```

**Returns:** Numeric build number

**Example:**
```basic
println "Build number: "; os_build()
' Windows 10 21H2: 19044
' Windows 11 22H2: 22621
```

**Note:** Build numbers are particularly useful on Windows to distinguish between feature updates that share the same major/minor version.

---

## Architecture Information

### os_architecture$()

Returns the processor architecture of the operating system.

**Syntax:**
```basic
arch$ = os_architecture$()
```

**Returns:** String identifying the architecture

**Possible Values:**

| Value | Description |
|-------|-------------|
| `"X86"` | 32-bit Intel/AMD x86 |
| `"X64"` | 64-bit Intel/AMD x86-64 |
| `"ARM32"` | 32-bit ARM |
| `"ARM64"` | 64-bit ARM (Apple Silicon, Snapdragon, etc.) |

**Example:**
```basic
println "Architecture: "; os_architecture$()
' Intel/AMD 64-bit: "X64"
' Apple Silicon Mac: "ARM64"
' Modern Android: "ARM64"
' Raspberry Pi 32-bit: "ARM32"
```

---

## Version Checking

### os_check() - Two Parameters

Checks if the operating system meets a minimum version requirement.

**Syntax:**
```basic
result = os_check(majorVersion, minorVersion)
```

**Parameters:**
- `majorVersion`: Required major version number
- `minorVersion`: Required minor version number

**Returns:** 
- `1` if the OS version is greater than or equal to the specified version
- `0` if the OS version is less than the specified version

**Example:**
```basic
' Check if running Windows 10 or later
if os_check(10, 0) = 1 then
    println "Windows 10 or later detected"
else
    println "Older Windows version"
endif

' Check if running macOS Monterey (12.0) or later
if os_check(12, 0) = 1 then
    println "macOS Monterey or later"
endif
```

---

### os_check() - Three Parameters

Checks if the operating system meets a minimum version requirement, including service pack level (Windows-specific).

**Syntax:**
```basic
result = os_check(majorVersion, minorVersion, servicePack)
```

**Parameters:**
- `majorVersion`: Required major version number
- `minorVersion`: Required minor version number
- `servicePack`: Required service pack major version

**Returns:** 
- `1` if the OS meets or exceeds the requirements
- `0` otherwise

**Example:**
```basic
' Check for Windows 7 SP1 or later
if os_check(6, 1, 1) = 1 then
    println "Windows 7 SP1 or later"
endif
```

**Note:** Service packs are primarily a Windows concept. On other platforms, the service pack value is typically 0.

---

## Service Pack Information

### os_spmajor()

Returns the major service pack version number (primarily for Windows).

**Syntax:**
```basic
spMajor = os_spmajor()
```

**Returns:** Service pack major version number (0 if no service pack)

**Example:**
```basic
sp = os_spmajor()
if sp > 0 then
    println "Service Pack "; sp; " installed"
else
    println "No service pack or N/A"
endif
```

---

### os_spminor()

Returns the minor service pack version number.

**Syntax:**
```basic
spMinor = os_spminor()
```

**Returns:** Service pack minor version number

**Example:**
```basic
println "Service Pack: "; os_spmajor(); "."; os_spminor()
```

**Note:** Modern operating systems (Windows 10/11, recent macOS) typically don't use service packs. These functions will return 0 on such systems.

---

## Complete Examples

### Example 1: System Information Display

```basic
' Display comprehensive system information
println "========================================="
println "        SYSTEM INFORMATION"
println "========================================="
println ""
println "Platform:     "; os_platform$()
println "OS Name:      "; os_name$()
println "Version:      "; os_major(); "."; os_minor()
println "Build:        "; os_build()
println "Architecture: "; os_architecture$()

sp = os_spmajor()
if sp > 0 then
    println "Service Pack: "; sp; "."; os_spminor()
endif

println ""
println "========================================="
```

---

### Example 2: Platform Detection

```basic
' Detect which platform we're running on and adapt behavior
println "=== Platform Detection ==="

osName$ = os_name$()

if osName$ = "Windows" then
    println "Running on Windows"
    println "Build: "; os_build()
    
    ' Check for Windows 10/11
    if os_check(10, 0) = 1 then
        if os_build() >= 22000 then
            println "This is Windows 11"
        else
            println "This is Windows 10"
        endif
    endif
    
else if osName$ = "macOS" then
    println "Running on macOS"
    
    major = os_major()
    if major >= 14 then
        println "macOS Sonoma or later"
    else if major >= 13 then
        println "macOS Ventura"
    else if major >= 12 then
        println "macOS Monterey"
    else
        println "Older macOS version"
    endif
    
else if osName$ = "iOS" then
    println "Running on iOS (iPhone/iPad)"
    println "Version: "; os_major(); "."; os_minor()
    
else if osName$ = "Android" then
    println "Running on Android"
    println "API Level corresponds to version "; os_major()
    
else
    println "Running on: "; osName$
endif
```

---

### Example 3: Architecture-Based Decisions

```basic
' Make decisions based on architecture
println "=== Architecture Check ==="

arch$ = os_architecture$()
println "Detected architecture: "; arch$

if arch$ = "IntelX64" then
    println "64-bit Intel/AMD processor"
    println "Full compatibility with x86 and x64 code"
    
else if arch$ = "X86" then
    println "32-bit Intel/AMD processor"
    println "Limited to 32-bit applications"
    println "Maximum ~3GB RAM addressable"
    
else if arch$ = "ARM64" then
    println "64-bit ARM processor"
    println "Energy efficient architecture"
    println "Common in mobile devices and Apple Silicon"
    
else if arch$ = "ARM32" then
    println "32-bit ARM processor"
    println "Older mobile devices or embedded systems"
    
else
    println "Unknown architecture: "; arch$
endif
```

---

### Example 4: Compatibility Checker

```basic
' Check if system meets minimum requirements
function checkRequirements() local meetsReq, arch$, reason$, osName$
    meetsReq = 1
    reason$ = ""
    
    ' Check OS version (example: require Windows 10+ or macOS 11+)
    osName$ = os_name$()
    
    if osName$ = "Windows" then
        if os_check(10, 0) = 0 then
            meetsReq = 0
            reason$ = "Requires Windows 10 or later"
        endif
    else if osName$ = "macOS" then
        if os_check(11, 0) = 0 then
            meetsReq = 0
            reason$ = "Requires macOS Big Sur (11.0) or later"
        endif
    endif
    
    ' Check architecture (example: require 64-bit)
    arch$ = os_architecture$()
    if arch$ = "X86" or arch$ = "ARM32" then
        meetsReq = 0
        reason$ = "Requires 64-bit operating system"
    endif
    
    if meetsReq = 1 then
        println "✓ System meets all requirements"
    else
        println "✗ System does not meet requirements"
        println "  Reason: "; reason$
    endif
    
    return meetsReq
endfunction

println "=== Compatibility Check ==="
println ""
result = checkRequirements()
```

---

### Example 5: About Box Information

```basic
' Generate "About" information for an application
println "========================================="
println "          MY APPLICATION v1.0"
println "========================================="
println ""
println "Copyright (c) 2025 Your Company"
println ""
println "----- System Information -----"
println ""

' Format version string
version$ = Str$(os_major()) + "." + Str$(os_minor())
if os_build() > 0 then
    version$ = version$ + " (Build " + Str$(os_build()) + ")"
endif

println "OS:           "; os_name$()
println "Version:      "; version$
println "Architecture: "; os_architecture$()

' Add platform-specific details
osName$ = os_name$()
if osName$ = "Windows" then
    if os_build() >= 22000 then
        println "Edition:      Windows 11"
    else
        println "Edition:      Windows 10"
    endif
endif

println ""
println "========================================="
```

---

### Example 6: Log File Header

```basic
' Create a log file header with system information
function logSystemInfo() local separator$
    separator$ = "----------------------------------------"
    
    println separator$
    println "LOG SESSION STARTED"
    println "Date: "; date$(); " "; time$()
    println separator$
    println "SYSTEM ENVIRONMENT:"
    println "  Platform:     "; os_platform$()
    println "  Architecture: "; os_architecture$()
    println "  OS Version:   "; os_major(); "."; os_minor(); "."; os_build()
    println separator$
    println ""
    
    return 1
endfunction

logSystemInfo()
println "Application starting..."
println "Loading configuration..."
```

---

## Quick Reference

### Version Information
```basic
os_platform$()       ' Full platform description string
os_name$()           ' OS name ("Windows", "macOS", "iOS", "Android")
os_major()           ' Major version number
os_minor()           ' Minor version number
os_build()           ' Build number
```

### Architecture
```basic
os_architecture$()   ' "X86", "X64", "ARM32", or "ARM64"
```

### Version Checking
```basic
os_check(major, minor)           ' Check minimum version (returns 1 or 0)
os_check(major, minor, sp)       ' Check with service pack
```

### Service Pack (Windows)
```basic
os_spmajor()         ' Service pack major version
os_spminor()         ' Service pack minor version
```

---

## Platform-Specific Notes

### Windows Version Numbers

| Windows Version | Major | Minor | Build Range |
|-----------------|-------|-------|-------------|
| Windows 7 | 6 | 1 | 7600-7601 |
| Windows 8 | 6 | 2 | 9200 |
| Windows 8.1 | 6 | 3 | 9600 |
| Windows 10 | 10 | 0 | 10240-19045 |
| Windows 11 | 10 | 0 | 22000+ |

**Note:** Windows 11 reports as version 10.0; use build number (≥22000) to distinguish.

### macOS Version Numbers

| macOS Version | Major | Minor |
|---------------|-------|-------|
| Big Sur | 11 | 0-7 |
| Monterey | 12 | 0-7 |
| Ventura | 13 | 0-6 |
| Sonoma | 14 | 0+ |

### iOS Version Numbers

iOS versions follow a simple major.minor.patch scheme corresponding to the iOS release (e.g., iOS 16.5 returns major=16, minor=5).

### Android Version Numbers

Android returns the major version number corresponding to the Android release (e.g., Android 13 returns major=13).

---

*End of PlatformInfoLib Documentation*
