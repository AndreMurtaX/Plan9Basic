' =============================================
' Plan9Basic - PlatformInfoLib Test
' Tests: Operating system information
' =============================================
PRINTLN "=== PlatformInfoLib Function Tests ==="
PRINTLN ""
PRINTLN "=========================================="
PRINTLN "    OPERATING SYSTEM INFORMATION"
PRINTLN "=========================================="
PRINTLN ""
' Platform info
PRINTLN "--- Platform ---"
PRINTLN "Full platform: "; os_platform$()
PRINTLN "OS Name: "; os_name$()
PRINTLN "Architecture: "; os_architecture$()
PRINTLN ""
' Version info
PRINTLN "--- Version ---"
PRINTLN "Major: "; os_major()
PRINTLN "Minor: "; os_minor()
PRINTLN "Build: "; os_build()
PRINTLN ""
' Service pack info
PRINTLN "--- Service Pack ---"
PRINTLN "SP Major: "; os_spmajor()
PRINTLN "SP Minor: "; os_spminor()
PRINTLN ""
' Version checks
PRINTLN "--- Version Checks ---"
PRINTLN "Is version >= 6.1 (Win7+): "; os_check(6, 1)
PRINTLN "Is version >= 10.0 (Win10+): "; os_check(10, 0)
PRINTLN ""
PRINTLN "=========================================="
PRINTLN ""
PRINTLN "=== PlatformInfoLib Tests Complete ==="
