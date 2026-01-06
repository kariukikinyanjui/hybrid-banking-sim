from django.urls import path, include

urlpatterns = [
    path('api/', include('wallet_app.urls')),
]
