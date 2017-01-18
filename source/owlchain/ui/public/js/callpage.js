$(document).ready(function() {
    // $.ajax();  <<< CORE METHOD
    // $('').load();
    // $.get();
    // $.post();
    // $.getScript();
    // $.getJSON();
    $('a').on('click', function(e) {
        e.preventDefault();
        var pageRef = $(this).attr('href');
        callPage(pageRef)
    });

    function callPage(pageRefInput) {
        // Using the core $.ajax() method
        $.ajax({
            url: pageRefInput,
            type: "GET",
            dataType: 'text',

            success: function(response) {
                console.log('the page was loaded', response);
                $('.content').html(response);
            },

            error: function(error) {
                console.log('the page was NOT loaded', error);
            },

            complete: function(xhr, status) {
                console.log("The request is complete!");
            }
        });
    }
});