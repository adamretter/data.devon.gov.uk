data.devon.gov.uk
=================
Initial attempt to define a RESTful API
for data.devon.gov.uk.

The implementation is in `data.xqm` and is built
using [eXist](http://exist-db.org) and [RESTXQ](http://www.adamretter.org.uk/papers/restful-xquery_january-2012.pdf).

In the following examples it is assumed that,
http://data.devon.gov.uk/ would be mapped to /data/,
so for example http://data.devon.gov.uk/community would
map to `/data/community`.

```
/data
/data/{$topic}
```

`$topic` is just a means of naming a collection
of related records/data. For example:

```
/data/finance
/data/community
```

```
/data/{$topic}/${dataset}
```

`$dataset` is the name of a dataset within
a particular topic area. For example:

```
/data/finance/over500
/data/community/service
```

Each `$dataset` will potentially have it's own URI
scheme and Query API. However, where possible
consideration should be given to making the 
URI schemes and Query APIs similar or common
across datasets; This then allows developers
to learn how to use one dataset and apply the
same knowledge to other datasets (where possible).

In this script we then implement an
alpha API for Community Services.


Content Manifestation
---------------------
The RESTful API should provide HTML, XML and JSON
manifestation of the data it serves.

The default representation will be HTML, whilst
the other representations will be provided through
content negotiation by means of the HTTP Accept header.

It may also be desirable to provide an RDF
representation in future or to look at adding
RDFa to the HTML representation.


Community Services RESTful API
==============================
Base Endpoint: `/data/community/service`

URI Endpoints:

* `/data/community/service`

    Provides links to all available service records. When
    the representation is expressed in HTML, it may also
    be pertinent to display a search form, or paging of the
    results.

* `/data/community/service/id/{$id}`

    The relative `$id` of a record, is the part that
    would come at the end of http://data.devon.gov.uk/community/service/{$id}.
    It is recommended that simple numeric identifiers are used and that
    these are further Base-32 encoded and expressed in lower-case to remove
    problems that may occur in verbal or written transcription. For example
    for record 300: http://data.devon.gov.uk/community/service/9c

* `/data/community/service/audience`

    Provides links to audiences which are generated
    by asking for the distinct-values of the `s:Audience` element in the
    Community Service XML documents. Each link would resolve to the
    following URI scheme `/data/community/service/audience/{$audience}`.

* `/data/community/service/audience/{$audience}`

    Provides links to records in the form of
    `/data/community/service/id/{$id}` that are applicable
    to a specific audience.
    The `$audience` is taken from the controlled vocabularly
    provided by `/data/community/service/audience` above.
    
* `/data/community/service/location`

    Provides links to locations which are generated
    by asking for the distinct-values of the `s:GeographicArea` element in the
    Community Service XML documents. Each link would resolve to the
    following URI scheme `/data/community/service/location/{$location}`.
    
* `/data/community/service/location/{$location}`

    Provides links to records in the form of
    `/data/community/service/id/{$id}` that are applicable
    to a specific location.
    The `$location` is taken from the controlled vocabularly
    provided by `/data/community/service/location` above.

* `/data/community/service/category`

    Provides links to categories which are generated
    by asking for the distinct-values of the `s:Category` element in the
    Community Service XML documents. Each link would resolve to the
    following URI scheme `/data/community/service/category/{$category}`.

* `/data/community/service/category/{$category}`

    Provides links to records in the form of
    `/data/community/service/id/{$id}` that are applicable
    to a specific category.
    The `$category` is taken from the controlled vocabularly
    provided by `/data/community/service/category` above.


Query parameters
----------------
All query parameters should also be expressable in lower-case in the URL.
All query parameters are optional, and should be applicable to any of the
Community Services RESTful API endpoints.

* `ageFrom=int`

    Matched on the `s:ageFrom` element of the Communuty Service XML documents.

* `ageTo=int`

    Matched on the `s:ageFrom` element of the Communuty Service XML documents.
    
* `keyword=string`

    Matched on the fulltext of the `s:Name` and `s:Description` element of
    the Communuty Service XML documents.

TODO
====
At present *only* the following are implemented for HTML, JSON and XML:
```
    /data
    /data/{$topic}
    /data/community/service
```

and for just XML:
```
    /data/community/service/{$id}
```
