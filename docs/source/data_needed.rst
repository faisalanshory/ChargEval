.. _data_needed:

================
Data Requirement
================

The data requirements of ChargEval can be classified into two categories, static and dynamic. 

.. (also cross-link these with the respective models, so each model should have a link to the dataset it uses. Maybe here mention all the models that this dataset is used in.) 

Static Datasets
===============

These datasets do not change or may change very infrequently to warrant an update strategy. 

WA State Road Network
---------------------
The WA State road network is used to simulate road travel. The road network was downloaded as shapefile from a source similar to `WA Public Roads Review Map`_ and its SRID converted to `EPSG:4326`_.

Shortest Paths
--------------
The shortest path between an origin and destination zip was calculated using the function :code:`sp_len()` which utilizes the pgRouting function :code:`pgr_dijkstra()`. The shortest path lengths are used in the trip generation process, for calculating the utility of travel in different modes. 

Zipcode Details
---------------
The details about the zipcodes needed include the lat-long of the centroid of the zipcode. For this purpose, the R package `zipcode`_ is used. To install the latest version use: 

.. code-block:: R

   install.packages("https://cran.r-project.org/src/contrib/Archive/zipcode/zipcode_1.0.tar.gz", repos = NULL, type="source")


.. (test and add link for script for zipcode). 




Dynamic Datasets
================

These datasets should be periodically updated. Currently, this process is manual. The suggested update frequency is explained with the dataset description. 

.. _wa-evses:

WA EVSEs
--------
This dataset contains information about the location and specifications including price, plug count and plug type for the various EVSEs in the state of WA. The location, plug type and plug count information is available from `AFDC portal`_. The portal also features a developer API which allows programmtic access to the locations in real-time. The price information provided by AFDC is in a string format ranging from 'Free' for free to use charging stations to more complex pricing schemes like '$2 per hour, minimum payment of $2' and 'Pricing is by session. $2 per session, maximum session time is 24 hours'. This information is hard to process for the Vehicle Choice Decision Model and Charging Choice Decision Model. Further, AFDC does not mention anything about the parking price while charging, which is an additional cost while charging. Hence, a simplistic pricing scheme is assumed for all non-free charging stations, which considers the total charging price (and similarly parking price) to consist of fixed charging price plus a variable charging price, which depends on the time or energy used. To represent this information, six new columns are added in the dataset, namely:

* DCFC Fixed Charging Price: Representing the fixed component of charging price, in dollars. 
* DCFC Variable Charging Price Unit: To store the unit of measurement for the variable price component, kWh or min. 
* DCFC Variable Charging Price: Depending on the value of the unit column, this price is either in $/kWh or $/min. 
* DCFC Fixed Parking Price: The fixed component of parking price, in dollars. 
* DCFC Variable Parking Price Unit: The unit can be min or hours. 
* DCFC Variable Parking Price: The variable parking price can in $/min or $/hour. 

.. note:: 
    No free sources of detailed pricing information was found, hence the price aggregation has to be done manually. 

WA Gas Prices 
-------------
This dataset aims to capture the variation of gas prices across WA. This dataset should be updated monthly. 

.. warning::
    While originally gasbuddy API was used for harvesting the data for all zip codes across WA, the API is undocumented and unsupported. Therefore, this method of gas price update is not stable and subject to error. A manual audit of harvested data is highly recommended. 

The gas prices are needed for the trip generation stage, specifically for calculating the vehicle choice, in calculating the utility of own ICE vehicle and rental ICE travel. The cost of gas is assumed same for personal ICE and rental ICE.

.. _wa-bevs:

WA BEVs
-------

The dataset *wa_bevs* corresponds to battery electric vehicles in the state of WA. This table is generated using the script `update_bevs.R`_. This script should be run monthly or more frequently if desired. The EV population data is collected from the `Data.WA.gov`_ portal (needs registration for API access). The vehicle specifications like the range and capacity were obtained from the  `fueleconomy.gov`_ portal. The resulting dataset was then filtered to only include the vehicles that support DC fast charging according to the following rules (deduced from web research): 

- No vehicles before 2008 supported fast charging. 
- Other vehicles filtered include makes "Fiat", "Azure Dynamics", "Smart" and "Th!nk" and models "Coda" (coda Automotive), "Life" (Wheego Electric Cars), and "Roadster" (Tesla). 

Further, a connector code of 4 is assigned to Tesla vehicles. A connector code of 1 is assigned to `CHAdeMO`_ which,  as of this writing in WA included vehicles of make "Nissan", "Mitsubishi", "Toyota", "Kia", "Honda", and Hyundai". A connector code of 2 is assigned to `CCS`_ (Combo 1 and 2) which, as of this writing in WA included vehicles of make "BMW", "Volkswagen", "Chevrolet", :Mercedez-Benz", "Ford", "Jaguar", "Audi", and "MINI". 

.. note::
    This step of encoding vehicles charging type (whether DC fast, charging power and charging standard) is manual since no free database was found that presents this information. 

Maximum Spacing Between Charging Stations Along a Route
-------------------------------------------------------

The maximum spacing is dependent on the type of charger, i.e. CHAdeMO, Combo or Tesla. This value changes if new chargers are added.  Following algorithm is used in the `get_max_spacing()`_ implementation: 

- A table is created that contains the EVSEs for simulation that includes the build EVSEs as well as the proposed EVSEs. 

- EVSEs are selected that are within, a certain distance (10 miles) from the route (shortest path between origin and destination zip).

- Ratio of points that are closest to the said charging stations along the route are found using PostGIS function :code:`ST_LineLocatePoint()`. 

- The ratios are sorted, and ratios with maximum consecutive difference are found. 

- The difference in ratios multiplied with the length of the route, gives the max spacing of charging stations for the route, for the particular charging station deployment scenario. 

This data is needed in trip generation, for calculating the utility of using an EV during a trip. As more chargers are added, the maximum spacing can go down for certain routes. 

Restaurant Availability
-----------------------

This boolean keeps a record of availability of restaurant at the site of charging station and is currently kept constant at 1 (meaning restaurant is available). It is used in the trip generation to calculate the utility of EV for the trip.

Cost of a Rental Car 
--------------------

Currently, this is kept fixed at $50 (per day). This is needed in trip generation, for calculating the utility of using a rental car for the trip. 

Fuel Economy of Rental Car
--------------------------

Currently, this is kept fixed at 25 (miles per gallon). This is needed in trip generation, for calculating the utility of using a rental car for the trip. 

Fuel Economy of Personally Owned ICE Car
----------------------------------------

Currently, this is kept fixed at 23 (miles per gallon). This is needed in trip generation, for calculating the utility of using own ICE car for the trip. 

Restroom Spacing Along the Route
--------------------------------

Currently, this is kept fixed at 20 (miles). This is needed in trip generation, for calculating the utility of using an EV for the trip. 

Destination Charger (L2 and Fast)
---------------------------------

This boolen value captures whether there is a charge station at the destination. This dataset is captured in the table :code:`dest_charger` of the database. This table contains a row for each zip code with values whether a destination charger exists within 10 miles of the destination zip. Further, this table is updated with new rows for each simulation request based consider the additional charging stations. This is needed for trip generation. 

Amenity (restroom and more) at Charging Station
-----------------------------------------------

These variables (amenity-restroom, and amenity-more) are booleans that capture the extent of amenities at the charging station. Amenity-more refers to the availability of restaurant (and Wifi) at the site. Currently, both these are kept constant at 1 for all charging stations. 

WA EV Trips
-----------

TBD




.. _WA Public Roads Review Map: https://wsdot.maps.arcgis.com/apps/Viewer/index.html?appid=e1d3bf7788c14584a816559c6ccf51e6
.. _EPSG:4326: https://spatialreference.org/ref/epsg/wgs-84/
.. _zipcode: https://CRAN.R-project.org/package=zipcode
.. _update_bevs.R: https://github.com/chintanp/wsdot_evse_update_states/tree/awspack/R/update_bevs.R
.. _Data.WA.gov: https://data.wa.gov/Demographics/Electric-Vehicle-Population-Map-by-ZIP-Code/bhmw-igtj
.. _fueleconomy.gov: https://www.fueleconomy.gov/feg/ws/index.shtml
.. _CHAdeMO: https://en.wikipedia.org/wiki/CHAdeMO
.. _CCS: https://en.wikipedia.org/wiki/Combined_Charging_System
.. _AFDC portal: https://afdc.energy.gov/fuels/electricity_locations.html#/find/nearest?fuel=ELEC
.. _get_max_spacing(): https://github.com/chintanp/wsdot_evse_update_states/blob/c2d4b2d8224dfd1996922ccd018ce7991889e2b1/R/generate_evtrip_scenarios.R#L528