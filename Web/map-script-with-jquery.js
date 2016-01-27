
var map;
var points = [];
var markers = [];
var directionsService;
var directionsRenderer;
var currentPoins = 0;
var path;

function initMap() {
  //инициализация карты
  map = new google.maps.Map(document.getElementById('map'), {
    center: {lat: 50.449253, lng: 30.543584},
    zoom: 12
  });

  //инициализация поисковых штук
  directionsService = new google.maps.DirectionsService;
  directionsRenderer = new google.maps.DirectionsRenderer;
  directionsRenderer.setMap(map);
  //инициализация слушателя клика по карте
  google.maps.event.addListener(map, 'click', function(event){
  	addMarker(event.latLng, map)
  });

  //тестирую генерацию пути
	// addMarker({lat: 50.447448430362435, lng: 30.451526641845703}, map);
	// addMarker({lat: 50.458815461559844, lng: 30.52448272705078}, map);
	// calculateAndDisplayRoute(directionsService, directionsDisplay, points[0], points[1]);

}

	//функция добавляет маркер на карту и добавляет точку в массив
function addMarker(location, map){
	marker = drawMarker(location, map);
  	points.push(location);
  	markers.push(marker);
 	//тут я юзаю джейквери. потому что я тупой, но это для теста
	$('#points').append('<div>' + marker.getPosition() + '</div>')
}

// меторд рисует маркер на карте
function drawMarker (location, map) {
	var marker = new google.maps.Marker({
		position: location,
		map: map
	});
	return marker;
}

//запуск джейквери
$(document).ready(function(){
	$('#button').click(function(){
		calculateAndDisplayRoute(directionsService, directionsRenderer, points[0], points[1]);
	});
});


//этот метод рисует путь по рекесту, потому что какого-то хрена не работает нормальный метод для этого
function drawDirection (response) {

	var dir = [];
	for (var i = 0; i < response.routes[0].overview_path.length; i++) {
				dir.push({lat: response.routes[0].overview_path[i].lat(),
							lng:response.routes[0].overview_path[i].lng()});
	};

	path = new google.maps.Polyline({
		path: dir,
		strokeColor: "#3498db",
		strokeOpacity: 5.0,
    	strokeWeight: 5
	});

	path.setMap(map);
}

function calculateAndDisplayRoute(directionsService, directionsDisplay, pointStart, pointEnd){
	directionsService.route({
		origin: pointStart,
		destination: pointEnd,
		travelMode: google.maps.TravelMode.WALKING
	}, function(response, status){
		if (status === google.maps.DirectionsStatus.OK) {
			//пункт отладки 003
			// alert("failed 03: " + status);
			// alertObj(response);
			// alertObj(response.routes[0]);
			// alertObj(response.routes[0].overview_path);
			// alertObj(response.routes[0].overview_path[0]);
			// alert(response.routes[0].overview_path.length);
			// alert(response.routes[0].overview_path[0].lat());
			//тут отладка закончилась

			// drawDirection(response);
			// alertObj(directionsRenderer);

			directionsRenderer.setDirections(response);
			clearMarkers();
		} else {
			//пункт отладки 004
			alert("failed : " + status);
		}
	});
}

//скопипащеная функция отладки
function alertObj(obj) {
    var str = "";
    for(k in obj) {
        str += k+": "+ obj[k]+"\r\n";
    }
    alert(str);
}

//убирет маркеры с карты
function clearMarkers() {
  setMapOnAll(null);
}

//выставляет мкарту для всех маркеров
function setMapOnAll(map) {
  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(map);
  }
}

//удаляет маркеры с карты
function deleteMarkers() {
  clearMarkers();
  markers = [];
  path.setMap(null);
}
