// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
    $(document).ready(function(){
        $("#history").hide();
    	$(".history").click(function(){
            $(".history").hide();
        	var link = $(this).attr('id');
        	$("#historydiv").html(
        		"<img src=\"http://jimpunk.net/Loading/wp-content/uploads/loading1.gif\"/>"
			);
           // $(window).scrollTop($("#history").offset().top + $("#history").height );
            $("#history").slideToggle();
        	$.getJSON(link, function(data){
                $("#history").slideToggle();
        		htmlstr = "<br /><table class=\"table table-bordered table-striped\"><tr><td>Occurred</td><td>Store</td><td>price</td></tr>";
        		$.each(data,function(index,item){
        			var datetime = new Date(item.occurred);
        			var date = (datetime.getMonth()+1) + "/" + datetime.getDate() + "/" + datetime.getFullYear();
        			htmlstr += ("<tr><td>" + date + "</td><td>"+ item.store+"</td><td>" + item.price + "</td></tr>");
        		});
        		htmlstr += "</table>";
                $("#historydiv").html("");
        		$("#historytable").html(htmlstr);
             //   $(window).scrollTop($("#history").offset().top + $("#history").height );
                $("#history").slideToggle();
                
        	});

    	});
    });		