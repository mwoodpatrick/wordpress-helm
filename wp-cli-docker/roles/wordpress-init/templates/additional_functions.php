<?php
add_action('openid-connect-generic-update-user-using-current-claim', function( $user, $user_claim) {
    // Based on some data in the user_claim, modify the user.
    if ( array_key_exists( '{{ WP_OPENID_CONNECT_SETTINGS.role_key }}', $user_claim ) ) {
        if ( in_array('admin',$user_claim['{{ WP_OPENID_CONNECT_SETTINGS.role_key }}'] )) {
            $user->set_role( 'administrator' );
        }
        else {
            $user->set_role( 'contributor' );
        }
    }
}, 10, 2);
