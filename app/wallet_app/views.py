import os
import requests
from django.http import JsonResponse

def check_legacy_balance(request):
    """
    Simulates a hybrid cloud call.
    1. The Request originates in AWS (EKS Pod).
    2. It travels over a 'VPN' (Simulated Bridge).
    3. It lands on the On-Premise Mainframe (Legacy Container).
    """
    
    # 1. Configuration via Env Vars (12-Factor App)
    # We default to the Docker Network IP of the mainframe if not set.
    # In a real scenario, this would be the internal IP of the mainframe (e.g., 10.1.1.50)
    mainframe_url = os.environ.get('MAINFRAME_ENDPOINT', 'http://192.168.1.2:8000/api/balance')

    try:
        # 2. The Network Call
        # We set a strict timeout. If the VPN is congested or down, we fail fast.
        # This prevents the web server threads from hanging indefinitely.
        response = requests.get(mainframe_url, timeout=3)
        
        # 3. Success Path
        if response.status_code == 200:
            data = response.json()
            return JsonResponse({
                'status': 'success',
                'source': 'Legacy Mainframe (On-Prem)',
                'data': data
            })
        else:
            return JsonResponse({'status': 'error', 'message': 'Mainframe rejected request'}, status=502)

    except requests.exceptions.ConnectionError:
        # 4. Failure Path (The "VPN Down" Scenario)
        # This is what we expect to happen initially before we configure the bridge.
        return JsonResponse({
            'status': 'error', 
            'message': 'VPN Tunnel Down: Cannot reach Mainframe.'
        }, status=503)
        
    except requests.exceptions.Timeout:
        return JsonResponse({'status': 'error', 'message': 'Mainframe connection timed out'}, status=504)

def health_check(request):
    """Standard K8s Liveness Probe"""
    return JsonResponse({'status': 'healthy'})
