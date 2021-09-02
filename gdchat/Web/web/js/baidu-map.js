	BaiduMap={
		map:null,//百度地图对象
		marker:null,
		markerMenu:null,
		myGeo:null,
		point:null,
		lng:null,//经度
		lat:null, //纬度
		imgApiUrl:"https://api.map.baidu.com/staticimage?width=320&height=240&&zoom=15&markers="
		

	}
	
var map=null;
	$(function() {
		//位置
		
		mapInit();

		$("#place").click(function(){
			$("#map").modal('show');
			$("#mapSubmit").show();
			getLocation();
		});
		
		
		$("#mapSubmit").click(function(){
			if(myFn.isNil(BaiduMap.lng)||myFn.isNil(BaiduMap.lat)){
				ownAlert(3,"请先选择位置!");
				return;
			}

			getAddress(BaiduMap.point,function(address){
				var content=BaiduMap.imgApiUrl+BaiduMap.lng+","+BaiduMap.lat+"&zoom=15"
				var msg=WEBIM.createMessage(4,content);
				msg.location_x=BaiduMap.lat;
				msg.location_y=BaiduMap.lng;
				msg.objectId=address;
				UI.sendMsg(msg);
				$("#map").modal('hide');
			});
			
		});
		

	});
	
	function mapInit(){

			map = new BMap.Map("baiduMap",
			 	{minZoom:4,maxZoom:18,enableMapClick:false});
			BaiduMap.map=map;
			BaiduMap.myGeo = new BMap.Geocoder();
			map.addEventListener("click", mapClick);
			
			var po=new BMap.Point(116.4035,39.915);
			map.centerAndZoom(po,15);
			 //启用滚轮放大缩小  
		    map.enableScrollWheelZoom(true); 

		    map.addControl(new BMap.NavigationControl()); 
		    //启用键盘操作  
		    map.enableKeyboard(true);
			//禁用地图拖拽  
		    //map.disableDragging(true);  
		    //禁用滚轮放大缩小  
		    //map.disableScrollWheelZoom(true);  
		
	}

	function getLocation(){
		var geolocation = new BMap.Geolocation();
			geolocation.enableSDKLocation();
			geolocation.getCurrentPosition(function(rs){
				

				console.log("getLocation ===> "+JSON.stringify(rs));
				if(this.getStatus() == BMAP_STATUS_SUCCESS){
					BaiduMap.lat=rs.point.lat;
					BaiduMap.lng=rs.point.lng;
					addMarker(rs.point);
		 			mapPanTo(rs.point);

				}
				else {
					ownAlert(2,'failed'+this.getStatus());
				}        
			}, {
			enableHighAccuracy : true
			});
	

		
	}


	function mapClick (e){
		addMarker(e.point);
		BaiduMap.lat=e.point.lat;
		BaiduMap.lng=e.point.lng;
		BaiduMap.point=e.point;
	}
	function addMarker(point){
		var marker = new BMap.Marker(point);
	 			removeMarker();
	 			BaiduMap.marker=marker;
	 			BaiduMap.point=point;
	 			map.addOverlay(marker);
	 			marker.setAnimation(BMAP_ANIMATION_BOUNCE);
	 			
	 			//map.panTo();
	}
	function removeMarker(){
		if(myFn.notNull(BaiduMap.marker))
			map.removeOverlay(BaiduMap.marker);
	}
	function getAddress(pt,cb){
		if(myFn.isNil(BaiduMap.myGeo)){
			BaiduMap.myGeo = new BMap.Geocoder();
		}

		BaiduMap.myGeo.getLocation(pt, function(rs){
			var addComp = rs.addressComponents;
			var address=addComp.city + ", " + addComp.district + ", " +
			 addComp.street + ", " + addComp.streetNumber;
			cb(address);
		}); 
	}
	function showToMap(obj){
		var thisObj=$(obj);

			$("#map").modal('show');
			$("#mapSubmit").hide();
			
			var lat=parseFloat(thisObj.attr("lat")); 
			var lng=parseFloat(thisObj.attr("lng"));
			var point=new BMap.Point(lat,lng);
			addMarker(point);
			mapPanTo(point);
	}
	function mapPanTo(point){
		setTimeout(function () {  
        		map.panTo(point);
    		}, 2000);
	}

	function mapError(){

		if (navigator.geolocation){ 
			console.log("用浏览器获取坐标地址 ===>");
			var options = {
				  
				  timeout:20000,
				  maximumAge: 60*1000
				};
			navigator.geolocation.getCurrentPosition(function (position) {
	  				console.log("position ==> "+JSON.stringify(position));
			      //得到html5定位结果
			      var x = position.coords.longitude;
			      var y = position.coords.latitude;
			  
			     //由于html5定位的结果是国际标准gps，所以from=1，to=5
			     //下面的代码并非实际是这样，这里只是提供一个思路
			     BMap.convgps(x, y, 1, 5, function (convRst) {
			         var point = new BMap.Point(convRst.x, convRst.y);
			 
			         //这个部分和上面的代码是一样的
			         var marker = new BMap.Marker(point);
			         map.addOverlay(marker);
			         map.panTo(point);
			     })
			 
			 },function(error){
				console.log("position  error ==> "+error.code+"  "+error.message);
			 },options); 
		}else{

			var geolocation = new BMap.Geolocation();
			geolocation.enableSDKLocation();
			geolocation.getCurrentPosition(function(r){
				

				console.log("getLocation ===> "+JSON.stringify(rs));
				if(this.getStatus() == BMAP_STATUS_SUCCESS){
					BaiduMap.lat=rs.point.lat;
					BaiduMap.lng=rs.point.lng;
					addMarker(rs.point);
		 			mapPanTo(rs.point);

				}
				else {
					ownAlert(2,'failed'+this.getStatus());
				}        
			}, {
			enableHighAccuracy : true
			});
		}
	}