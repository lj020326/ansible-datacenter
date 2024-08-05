## ref: https://stackoverflow.com/questions/8074955/cannot-import-name-patterns
#from django.conf.urls import patterns
from django.conf.urls import *

import views

# Uncomment the next two lines to enable the admin:
# from cobbler_web.contrib import admin
# admin.autodiscover()

urlpatterns = [
    url(r'^$', include(views.index)),

    url(r'^setting/list$', include(views.setting_list)),
    url(r'^setting/edit/(?P<setting_name>.+)$', include(views.setting_edit)),
    url(r'^setting/save$', include(views.setting_save)),

    url(r'^ksfile/list(/(?P<page>\d+))?$', include(views.ksfile_list)),
    url(r'^ksfile/edit$', include(views.ksfile_edit), {'editmode':'new'}),
    url(r'^ksfile/edit/file:(?P<ksfile_name>.+)$', include(views.ksfile_edit), {'editmode':'edit'}),
    url(r'^ksfile/save$', include(views.ksfile_save)),

    url(r'^snippet/list(/(?P<page>\d+))?$', include(views.snippet_list)),
    url(r'^snippet/edit$', include(views.snippet_edit), {'editmode':'new'}),
    url(r'^snippet/edit/file:(?P<snippet_name>.+)$', include(views.snippet_edit), {'editmode':'edit'}),
    url(r'^snippet/save$', include(views.snippet_save)),

    url(r'^(?P<what>\w+)/list(/(?P<page>\d+))?', include(views.genlist)),
    url(r'^(?P<what>\w+)/modifylist/(?P<pref>[!\w]+)/(?P<value>.+)$', include(views.modify_list)),
    url(r'^(?P<what>\w+)/edit/(?P<obj_name>.+)$', include(views.generic_edit), {'editmode': 'edit'}),
    url(r'^(?P<what>\w+)/edit$', include(views.generic_edit), {'editmode': 'new'}),

    url(r'^(?P<what>\w+)/rename/(?P<obj_name>.+)/(?P<obj_newname>.+)$', include(views.generic_rename)),
    url(r'^(?P<what>\w+)/copy/(?P<obj_name>.+)/(?P<obj_newname>.+)$', include(views.generic_copy)),
    url(r'^(?P<what>\w+)/delete/(?P<obj_name>.+)$', include(views.generic_delete)),

    url(r'^(?P<what>\w+)/multi/(?P<multi_mode>.+)/(?P<multi_arg>.+)$', include(views.generic_domulti)),
    url(r'^utils/random_mac$', include(views.random_mac)),
    url(r'^utils/random_mac/virttype/(?P<virttype>.+)$', include(views.random_mac)),
    url(r'^events$', include(views.events)),
    url(r'^eventlog/(?P<event>.+)$', include(views.eventlog)),
    url(r'^iplist$', include(views.iplist)),
    url(r'^task_created$', include(views.task_created)),
    url(r'^sync$', include(views.sync)),
    url(r'^reposync$', include(views.reposync)),
    url(r'^replicate$', include(views.replicate)),
    url(r'^hardlink', include(views.hardlink)),
    url(r'^(?P<what>\w+)/save$', include(views.generic_save)),
    url(r'^import/prompt$', include(views.import_prompt)),
    url(r'^import/run$', include(views.import_run)),
    url(r'^buildiso$', include(views.buildiso)),
    url(r'^check$', include(views.check)),

    url(r'^login$', include(views.login)),
    url(r'^do_login$', include(views.do_login)),
    url(r'^logout$', include(views.do_logout)),
]
