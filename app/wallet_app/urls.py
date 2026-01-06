from django.urls import path
from . import views

urlpatterns = [
    path('balance/', views.check_legacy_balance, name='check_balance'),
    path('health/', views.health_check, name='health_check'),
]
