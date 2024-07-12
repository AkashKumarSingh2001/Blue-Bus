// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"


$(document).ready(function(){
    var counter = 0;
    var busId = $("#bus_id").val(); // Get bus_id from hidden field
    var reservationId = $("#reservation_id").val(); // Get reservation_id from hidden field

    $('.trav-select-check').on('click', function(){
        if ($(this).prop('checked')) {
            counter += 1;
            $("#delete-travellers").show();
        } else {
            counter -= 1;
            if (counter <= 0) {
                $("#delete-travellers").hide();
            }
        }
    });

    $("#delete-travellers").on('click', function(){
        var travIds = [];

        $(".trav-select-check").each(function(){
            if ($(this).prop('checked')) {
                travIds.push($(this).data('trav-id'));
            }
        });

        // Confirmation dialog
        if (confirm("Are you sure you want to delete selected travellers?")) {
            // If confirmed, proceed with the AJAX request
            $.ajax({
                url: "/buses/" + busId + "/reservations/" + reservationId + "/travellers/bulk_delete_travellers",
                type: 'DELETE',
                data: {
                    trav_ids: travIds,
                    bus_id: busId,
                    reservation_id: reservationId
                }
            }).done(function(response) {
                // Handle response if needed
            }).fail(function(jqXHR, textStatus, errorThrown) {
                // Handle error if needed
            });
        }
    });
});



// document.addEventListener("DOMContentLoaded", function() {
//     const dateofjourney = document.getElementById("dateofjourney");
  
//     // Add event listener for date change
//     dateofjourney.addEventListener("change", function() {
//       // Submit the form when date changes
//       this.form.submit();
//     });
// });
  

  