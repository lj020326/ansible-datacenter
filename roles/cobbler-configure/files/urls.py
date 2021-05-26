## ref: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=856856
#from django.conf.urls import patterns, include
from django.conf.urls import include, url

# Uncomment the next two lines to enable the admin:
#from django.contrib import admin
#admin.autodiscover()

urlpatterns = [
    url(r'^', include('cobbler_web.urls')),
]
