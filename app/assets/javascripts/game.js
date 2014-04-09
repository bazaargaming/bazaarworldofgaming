// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
    $(document).ready(function(){
        $("#historydiv").hide();
        $("#historytable").hide();
        $("#historygraph").hide();
    	$(".history").click(function(){
            $(".history").hide();
            $("#history").prepend("<h3 class=\"header3\">Price History</h3>")
        	var link = $(this).attr('id');
        	$("#historydiv").html(
        		"<img src=\"http://jimpunk.net/Loading/wp-content/uploads/loading1.gif\"/>"
			);
            $("#historydiv").show();
           // $(window).scrollTop($("#history").offset().top + $("#history").height );
        	$.getJSON(link, function(data){
                $("#historydiv").hide();
                $("#historytable").show();
                $("#historygraph").show();


                
                var steamarr = data.filter(function(item){
                    return (item.store === "Steam");
                });
                var amazonarr = data.filter(function(item){
                    return (item.store === "Amazon");
                });
                var gmgarr = data.filter(function(item){
                    return (item.store === "GMG");
                });
                var unique = {};
                var distinctDates = new Array();
                
                htmlstr = "<br /><table class=\"table table-bordered table-striped\"><tr><td>Occurred</td><td>Store</td><td>price</td></tr>";
        		//$.each(data,function(index,item){
                for(var i = 0; i < data.length; i++){
                    var item = data[i];
                    var previous;
        			var datetime = new Date(item.occurred);
                    
        			var date = (datetime.getMonth()+1) + "/" + datetime.getDate() + "/" + datetime.getFullYear();
                    if(!unique[date]){
                        distinctDates.push(date);
                        unique[date] = true;
                    }
                   
                    htmlstr += ("<tr><td>" + date + "</td><td>"+ item.store+"</td><td>" + item.price + "</td></tr>");
                    
                    

        		}
                distinctDates.reverse();
                var graphhtml = "<table><caption> Price Hisotry</caption><thead><tr><td></td>";
                for(var i = 0; i < distinctDates.length; i++){

                    graphhtml += "<th>"+ distinctDates[i] + "</th>";

                }
                graphhtml += "</tr></thead><tbody><tr><th>Steam</th>"

                var cheapest=-1;
                var cheapestPrice = -1;
                var prevPrice = 0;
                steamarr.reverse();
                $.each(distinctDates, function(index, item){
                    
                    for( var i = 0; i < steamarr.length; i++){
                        var datetime = new Date(steamarr[i].occurred);
                        var date = (datetime.getMonth()+1) + "/" + datetime.getDate() + "/" + datetime.getFullYear();
                        if(date == item){
                            
                            idx = i;
                            if(cheapestPrice == -1){
                                cheapest = i;
                                cheapestPrice =  steamarr[i].price;
                            }
                            else{
                                if (cheapestPrice > steamarr[i].price) {
                                    cheapest = i;
                                    cheapestPrice = steamarr[i].price;
                                }
                            }
                        }

                    }
                    
                    if(cheapestPrice == -1){
                        if(index == 0){
                            graphhtml += "<td>0</td>";

                        }
                        else{
                            graphhtml += "<td>" + steamarr[prevPrice].price + "</td>"
                        }
                    }
                    else{
                        graphhtml += "<td>" + steamarr[cheapest].price + "</td>";
                        prevPrice = cheapest
                    }
                    cheapest = -1;
                    cheapestPrice = -1;
                });
                graphhtml += "</tr><tr><th>Amazon</th>";

                prevPrice = 0;
                amazonarr.reverse();
                $.each(distinctDates, function(index, item){
                    
                    for( i = 0; i < amazonarr.length; i++){
                        var datetime = new Date(amazonarr[i].occurred);
                        var date = (datetime.getMonth()+1) + "/" + datetime.getDate() + "/" + datetime.getFullYear();
                        if(date == item){
                            
                            if(cheapestPrice == -1){
                                cheapest = i;
                                cheapestPrice =  amazonarr[i].price;
                            }
                            else{
                                if (cheapestPrice > amazonarr[i].price) {
                                    cheapest = i;
                                    cheapestPrice = amazonarr[i].price;
                                }
                            }
                        }

                    }
                    
                    if(cheapestPrice == -1){
                        if(index == 0){
                            graphhtml += "<td>0</td>";

                        }
                        else{
                            graphhtml += "<td>" + amazonarr[prevPrice].price + "</td>"
                        }
                    }
                    else{
                        prevPrice = cheapest;
                        graphhtml += "<td>" + amazonarr[cheapest].price + "</td>";
                    }
                    cheapest = -1;
                    cheapestPrice = -1;
                });
                graphhtml += "</tr><tr><th>GMG</th>";
                
                prevPrice = 0;
                gmgarr.reverse();
                $.each(distinctDates, function(index, item){
                    
                    for(i = 0; i < gmgarr.length; i++){
                        var datetime = new Date(gmgarr[i].occurred);
                        var date = (datetime.getMonth()+1) + "/" + datetime.getDate() + "/" + datetime.getFullYear();
                        if(date == item){
                            console.log(date);
                            if(cheapestPrice == -1){
                                cheapest = i;
                                cheapestPrice =  gmgarr[i].price;
                            }
                            else{
                                if (cheapestPrice > gmgarr[i].price) {
                                    cheapest = i;
                                    cheapestPrice = gmgarr[i].price;
                                }
                            }
                        }
                        

                    }
                    
                    if(cheapestPrice == -1){
                        
                        if(index == 0){
                            graphhtml += "<td>0</td>";

                        }

                        else{
                            graphhtml += "<td>" + gmgarr[prevPrice].price + "</td>"
                        }
                    }
                    else{
                        prevPrice = cheapest;
                        graphhtml += "<td>" + gmgarr[cheapest].price + "</td>";
                    }
                    cheapest = -1;
                    cheapestPrice = -1;
                });
                graphhtml += "</tr></tbody></table>";

               
                $("#historydiv").html("");
        		$("#historytable").html(htmlstr);
                $("#historygraph").html(graphhtml);

                $('#historygraph').visualize({type: "line"});
                $("#historygraph").hide();
                console.log(graphhtml);
                
                //var plot = $.jqplot('historygraph', [[3,7,9,1,4,6,8,2,5]]);
                
        	});

    	});
    });		