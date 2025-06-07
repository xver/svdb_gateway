import subprocess
import sys

def test_help():
    result = subprocess.run([sys.executable, '../../py/xml_to_sqlite.py', '--help'], capture_output=True, text=True)
    assert result.returncode == 0
    assert 'usage' in result.stdout.lower() or 'usage' in result.stderr.lower()

if __name__ == '__main__':
    test_help()
    print('xml_to_sqlite.py help test passed.')