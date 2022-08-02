from rest_framework import mixins
from rest_framework.views import APIView
from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.authentication import TokenAuthentication
from rest_framework import filters
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.settings import api_settings
from rest_framework import permissions as rf_permissions

from qrtick_app import models
from qrtick_app import serializers
from qrtick_app import permissions

from datetime import datetime, date


class UserAuthenticationView(viewsets.ModelViewSet):
    serializer_class = serializers.UserAuthenticationSerializer
    queryset = models.UserAuthentication.objects.all()

    authentication_classes = (TokenAuthentication,)
    permission_classes = (permissions.UpdateOwnAuthorization,rf_permissions.IsAdminUser)

    filter_backends = (filters.SearchFilter,)
    search_fields = ('user_id',)


class UserLoginView(ObtainAuthToken):
    permission_classes = (rf_permissions.AllowAny,)
    """Handle creating user authentication tokens"""
    renderer_classes = api_settings.DEFAULT_RENDERER_CLASSES


class UserProfileView(viewsets.ModelViewSet):
    serializer_class = serializers.UserProfileSerializer
    queryset = models.UserProfile.objects.all()

    authentication_classes = (TokenAuthentication,)
    permission_classes = (permissions.UpdateOwnProfile,)


class WorkScheduleView(viewsets.ModelViewSet):
    serializer_class = serializers.WorkScheduleSerializer
    queryset = models.WorkSchedule.objects.all().order_by("id")

    authentication_classes = (TokenAuthentication,)
    permission_classes = (permissions.UpdateWorkSchedule,)


class QRCODEView(viewsets.ModelViewSet):
    serializer_class = serializers.QRCODESerializer
    queryset = models.QRCODE.objects.all()

    authentication_classes = (TokenAuthentication,)
    permission_classes = (permissions.UpdateWorkSchedule,)


class CheckQRCODEView(APIView):
    serializer_class = serializers.CheckQRCODESerializer

    authentication_classes = (TokenAuthentication,)
    permission_classes = (rf_permissions.IsAuthenticated,)

    def post(self, request):
        serializer = self.serializer_class(data=request.data)
        if serializer.is_valid():
            if serializer.validated_data.get('scanned_qr_code') == models.QRCODE.objects.get(id='qr_code_id').qr_code:
                return Response({'message': 'CORRECT'}, status=status.HTTP_200_OK)
            else:
                return Response({'message': 'INCORRECT'}, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ArrivalDepartureView(viewsets.ModelViewSet):
    serializer_class = serializers.ArrivalDepartureSerializer
    queryset = models.ArrivalDeparture.objects.all().order_by('-date', 'arrival_time')

    authentication_classes = (TokenAuthentication,)
    permission_classes = (rf_permissions.IsAuthenticated,)

    filter_backends = (filters.SearchFilter,)
    search_fields = ('id', 'user_id__user_id__user_id', 'date__month', 'date__year', )


class IsStaffView(APIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (rf_permissions.IsAuthenticated,)

    def get(self, request):
        if models.UserAuthentication.objects.get(id=request.user.id).is_staff:
            return Response({'message': True}, status=status.HTTP_200_OK)
        else:
            return Response({'message': False}, status=status.HTTP_200_OK)


class CurrentScheduleView(APIView):
    authentication_classes = (TokenAuthentication,)
    permission_classes = (rf_permissions.IsAuthenticated,)

    def get(self, request):
        schedule = models.WorkSchedule.objects.get(id=datetime.now().weekday())
        from_time = schedule.from_time
        to_time = schedule.to_time
        if from_time is not None and to_time is not None:
            return Response({'from_time': from_time.strftime("%H:%M"), 'to_time': to_time.strftime("%H:%M"),
                         'date': date.today().strftime("%d-%m-%Y"), 'month_year': date.today().strftime("%B(%Y)"), 'day_of_week': schedule.day_of_week})

        return Response({'from_time': '--:--', 'to_time': '--:--',
                         'date': date.today().strftime("%d-%m-%Y"), 'month_year': date.today().strftime("%B(%Y)"), 'day_of_week': schedule.day_of_week})



