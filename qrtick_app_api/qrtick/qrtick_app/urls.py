from django.urls import path, include
from rest_framework.routers import DefaultRouter

from qrtick_app import views

router = DefaultRouter()
router.register('auth', views.UserAuthenticationView)
router.register('profile', views.UserProfileView)
router.register('work_schedule', views.WorkScheduleView)
router.register('update_qr_code', views.QRCODEView)
router.register('arrival_departure', views.ArrivalDepartureView)


urlpatterns = [
    path('', include(router.urls)),
    path('login/', views.UserLoginView.as_view()),
    path('check_qr_code/', views.CheckQRCODEView.as_view()),
    path('is_staff/', views.IsStaffView.as_view()),
    path('current_schedule/', views.CurrentScheduleView.as_view()),
]