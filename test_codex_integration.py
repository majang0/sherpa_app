#!/usr/bin/env python3
"""
Test script for Codex Bridge MCP integration
Tests both direct Codex CLI and Codex Bridge MCP functionality
"""

import subprocess
import json
import os
import sys

# Set UTF-8 encoding for Windows console
if os.name == 'nt':
    import codecs
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer, 'strict')
    sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer, 'strict')

def test_direct_codex():
    """Test direct Codex CLI execution"""
    print("[TEST] Testing direct Codex CLI...")
    try:
        # On Windows, use codex.cmd
        cmd = ['codex.cmd' if os.name == 'nt' else 'codex', 'exec', 'What is the purpose of the Sherpa app?']
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding='utf-8',
            shell=(os.name == 'nt')  # Use shell on Windows for .cmd files
        )
        
        if result.returncode == 0:
            print("[OK] Direct Codex CLI works!")
            print(f"Output preview: {result.stdout[:200]}...")
            return True
        else:
            print(f"[FAIL] Direct Codex CLI failed: {result.stderr[:200]}")
            return False
    except Exception as e:
        print(f"[ERROR] Error testing direct Codex: {e}")
        return False

def test_codex_bridge_mcp():
    """Test Codex Bridge MCP functionality"""
    print("\n[TEST] Testing Codex Bridge MCP...")
    
    # Create a test query for the MCP
    test_query = {
        "query": "Explain the main features of the Sherpa App",
        "directory": os.getcwd(),
        "format": "json",
        "timeout": 60
    }
    
    # Try to import and use codex_bridge directly
    try:
        # First, let's check if we can import the module
        import codex_bridge
        print("[OK] Codex Bridge module imported successfully")
        
        # Try to find the main function
        if hasattr(codex_bridge, '__version__'):
            print(f"   Version: {codex_bridge.__version__}")
        
        return True
    except ImportError as e:
        print(f"[WARN] Codex Bridge module not directly importable: {e}")
        
    # Alternative: Test via subprocess
    try:
        print("[INFO] Testing via subprocess...")
        
        # Create a simple Python script to test the MCP
        test_script = '''
import os
import sys
import platform

# Set environment variable for Windows
if platform.system() == "Windows":
    os.environ["CODEX_CMD"] = "codex.cmd"

# Try to run codex-bridge
try:
    from codex_bridge import __main__
    print("Codex Bridge loaded successfully")
except Exception as e:
    print(f"Error: {e}")
'''
        
        result = subprocess.run(
            [sys.executable, '-c', test_script],
            capture_output=True,
            text=True,
            encoding='utf-8'
        )
        
        if "successfully" in result.stdout:
            print("[OK] Codex Bridge subprocess test passed")
            return True
        else:
            print(f"[WARN] Codex Bridge subprocess test output: {result.stdout}")
            if result.stderr:
                print(f"   Stderr: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"[ERROR] Error testing Codex Bridge MCP: {e}")
        return False

def create_wrapper_script():
    """Create a wrapper script for Windows compatibility"""
    print("\n[INFO] Creating Windows wrapper script...")
    
    wrapper_content = '''@echo off
REM Wrapper script for Codex on Windows
codex.cmd %*
'''
    
    wrapper_path = os.path.join(os.path.dirname(sys.executable), "Scripts", "codex.bat")
    
    try:
        with open(wrapper_path, 'w') as f:
            f.write(wrapper_content)
        print(f"[OK] Created wrapper script at: {wrapper_path}")
        return wrapper_path
    except Exception as e:
        print(f"[ERROR] Failed to create wrapper: {e}")
        
        # Try alternative location
        alt_path = "C:\\sherpa_app\\codex_wrapper.bat"
        try:
            with open(alt_path, 'w') as f:
                f.write(wrapper_content)
            print(f"[OK] Created wrapper script at alternative location: {alt_path}")
            return alt_path
        except Exception as e2:
            print(f"[ERROR] Failed to create alternative wrapper: {e2}")
            return None

def test_mcp_with_wrapper(wrapper_path):
    """Test if the wrapper helps with MCP integration"""
    if not wrapper_path:
        return False
        
    print(f"\n[TEST] Testing MCP with wrapper at: {wrapper_path}")
    
    # Add wrapper directory to PATH temporarily
    original_path = os.environ.get('PATH', '')
    wrapper_dir = os.path.dirname(wrapper_path)
    os.environ['PATH'] = f"{wrapper_dir};{original_path}"
    
    try:
        # Test if 'codex' command now works
        result = subprocess.run(
            ['codex', '--version'],
            capture_output=True,
            text=True,
            encoding='utf-8',
            shell=True
        )
        
        if result.returncode == 0:
            print("[OK] Wrapper enables 'codex' command!")
            return True
        else:
            print(f"[WARN] Wrapper didn't help: {result.stderr[:200]}")
            return False
    except Exception as e:
        print(f"[ERROR] Error testing wrapper: {e}")
        return False
    finally:
        # Restore original PATH
        os.environ['PATH'] = original_path

def main():
    """Main test execution"""
    print("=" * 60)
    print("Codex Bridge MCP Integration Test Suite")
    print("=" * 60)
    
    results = {}
    
    # Test 1: Direct Codex CLI
    results['direct_codex'] = test_direct_codex()
    
    # Test 2: Codex Bridge MCP
    results['codex_bridge'] = test_codex_bridge_mcp()
    
    # Test 3: Create wrapper if on Windows
    if os.name == 'nt':
        wrapper_path = create_wrapper_script()
        if wrapper_path:
            results['wrapper'] = test_mcp_with_wrapper(wrapper_path)
    
    # Summary
    print("\n" + "=" * 60)
    print("Test Results Summary:")
    print("=" * 60)
    
    for test_name, passed in results.items():
        status = "[PASSED]" if passed else "[FAILED]"
        print(f"  {test_name:20} : {status}")
    
    # Recommendations
    print("\n" + "=" * 60)
    print("Recommendations:")
    print("=" * 60)
    
    if results.get('direct_codex', False):
        print("[OK] Codex CLI is working properly")
        
        if not results.get('codex_bridge', False):
            print("[WARN] Codex Bridge MCP needs configuration:")
            print("   1. The MCP server needs to call 'codex.cmd' on Windows")
            print("   2. Consider using the wrapper script created")
            print("   3. Update MCP configuration with proper environment variables")
            
            print("\n[INFO] Suggested MCP configuration fix:")
            print('   claude mcp remove codex-bridge')
            print('   claude mcp add codex-bridge uvx codex-bridge')
            
            if os.name == 'nt':
                print("\n   Or create a custom integration script")
    else:
        print("[ERROR] Codex CLI is not working. Please ensure:")
        print("   1. Codex is installed: npm install -g @openai/codex-cli")
        print("   2. Codex is authenticated: codex auth")
        print("   3. PATH includes npm global bin directory")
    
    return all(results.values())

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)