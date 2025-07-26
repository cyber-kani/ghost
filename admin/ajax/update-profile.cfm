<!--- 
Profile Update Action Page
Handles AJAX requests for user profile updates based on Ghost CMS architecture
--->

<cfheader name="Content-Type" value="application/json">
<cfsetting requestTimeout="30">

<cfscript>
/**
 * Update user profile in database following Ghost CMS patterns
 */
function updateUserProfile(struct userData) {
    try {
        // Validate required fields
        if (!structKeyExists(userData, "userId") || len(trim(userData.userId)) == 0) {
            return {
                success: false,
                message: "User ID is required"
            };
        }
        
        if (!structKeyExists(userData, "name") || len(trim(userData.name)) == 0) {
            return {
                success: false,
                message: "Name is required"
            };
        }
        
        if (!structKeyExists(userData, "email") || len(trim(userData.email)) == 0 || !isValid("email", userData.email)) {
            return {
                success: false,
                message: "Valid email is required"
            };
        }
        
        if (!structKeyExists(userData, "slug") || len(trim(userData.slug)) == 0) {
            return {
                success: false,
                message: "Slug is required"
            };
        }
        
        // Check if email already exists for different user
        var emailCheck = queryExecute("
            SELECT id FROM users 
            WHERE email = :email AND id != :userId
        ", {
            email: {value: trim(userData.email), cfsqltype: "cf_sql_varchar"},
            userId: {value: trim(userData.userId), cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"});
        
        if (emailCheck.recordCount > 0) {
            return {
                success: false,
                message: "Email address is already in use"
            };
        }
        
        // Check if slug already exists for different user
        var slugCheck = queryExecute("
            SELECT id FROM users 
            WHERE slug = :slug AND id != :userId
        ", {
            slug: {value: trim(userData.slug), cfsqltype: "cf_sql_varchar"},
            userId: {value: trim(userData.userId), cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"});
        
        if (slugCheck.recordCount > 0) {
            return {
                success: false,
                message: "Slug is already in use"
            };
        }
        
        // Validate field lengths based on Ghost schema
        if (len(userData.name) > 191) {
            return {success: false, message: "Name must be 191 characters or less"};
        }
        if (len(userData.bio) > 250) {
            return {success: false, message: "Bio must be 250 characters or less"};
        }
        if (len(userData.location) > 150) {
            return {success: false, message: "Location must be 150 characters or less"};
        }
        if (len(userData.website) > 2000) {
            return {success: false, message: "Website URL is too long"};
        }
        
        // Validate URLs if provided
        if (len(trim(userData.website)) > 0 && !isValid("url", userData.website)) {
            return {success: false, message: "Website must be a valid URL"};
        }
        
        // Update user record
        var updateResult = queryExecute("
            UPDATE users SET
                name = :name,
                slug = :slug,
                email = :email,
                bio = :bio,
                location = :location,
                website = :website,
                facebook = :facebook,
                twitter = :twitter,
                threads = :threads,
                bluesky = :bluesky,
                linkedin = :linkedin,
                instagram = :instagram,
                youtube = :youtube,
                tiktok = :tiktok,
                mastodon = :mastodon,
                updated_at = :updatedAt,
                updated_by = :updatedBy
            WHERE id = :userId
        ", {
            name: {value: trim(userData.name), cfsqltype: "cf_sql_varchar"},
            slug: {value: trim(userData.slug), cfsqltype: "cf_sql_varchar"},
            email: {value: trim(userData.email), cfsqltype: "cf_sql_varchar"},
            bio: {value: trim(userData.bio ?: ""), cfsqltype: "cf_sql_longvarchar"},
            location: {value: trim(userData.location ?: ""), cfsqltype: "cf_sql_longvarchar"},
            website: {value: trim(userData.website ?: ""), cfsqltype: "cf_sql_varchar"},
            facebook: {value: trim(userData.facebook ?: ""), cfsqltype: "cf_sql_varchar"},
            twitter: {value: trim(userData.twitter ?: ""), cfsqltype: "cf_sql_varchar"},
            threads: {value: trim(userData.threads ?: ""), cfsqltype: "cf_sql_varchar"},
            bluesky: {value: trim(userData.bluesky ?: ""), cfsqltype: "cf_sql_varchar"},
            linkedin: {value: trim(userData.linkedin ?: ""), cfsqltype: "cf_sql_varchar"},
            instagram: {value: trim(userData.instagram ?: ""), cfsqltype: "cf_sql_varchar"},
            youtube: {value: trim(userData.youtube ?: ""), cfsqltype: "cf_sql_varchar"},
            tiktok: {value: trim(userData.tiktok ?: ""), cfsqltype: "cf_sql_varchar"},
            mastodon: {value: trim(userData.mastodon ?: ""), cfsqltype: "cf_sql_varchar"},
            updatedAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
            updatedBy: {value: trim(userData.userId), cfsqltype: "cf_sql_varchar"},
            userId: {value: trim(userData.userId), cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"});
        
        // Update session if needed
        if (structKeyExists(session, "user") && isStruct(session.user)) {
            session.user.name = trim(userData.name);
            session.user.email = trim(userData.email);
            session.user.slug = trim(userData.slug);
            session.user.bio = trim(userData.bio ?: "");
            session.user.location = trim(userData.location ?: "");
            session.user.website = trim(userData.website ?: "");
        }
        
        return {
            success: true,
            message: "Profile updated successfully",
            data: {
                name: trim(userData.name),
                email: trim(userData.email),
                slug: trim(userData.slug)
            }
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error updating profile: " & e.message
        };
    }
}

/**
 * Update notification preferences
 */
function updateNotificationPreferences(struct notificationData) {
    try {
        if (!structKeyExists(notificationData, "userId")) {
            return {success: false, message: "User ID is required"};
        }
        
        // Update notification preferences
        queryExecute("
            UPDATE users SET
                comment_notifications = :commentNotifications,
                mention_notifications = :mentionNotifications,
                milestone_notifications = :milestoneNotifications,
                free_member_signup_notification = :freeSignupNotifications,
                paid_subscription_started_notification = :paidStartedNotifications,
                paid_subscription_canceled_notification = :paidCanceledNotifications,
                recommendation_notifications = :recommendationNotifications,
                donation_notifications = :donationNotifications,
                updated_at = :updatedAt,
                updated_by = :updatedBy
            WHERE id = :userId
        ", {
            commentNotifications: {value: notificationData.commentNotifications ?: false, cfsqltype: "cf_sql_bit"},
            mentionNotifications: {value: notificationData.mentionNotifications ?: false, cfsqltype: "cf_sql_bit"},
            milestoneNotifications: {value: notificationData.milestoneNotifications ?: false, cfsqltype: "cf_sql_bit"},
            freeSignupNotifications: {value: notificationData.freeSignupNotifications ?: false, cfsqltype: "cf_sql_bit"},
            paidStartedNotifications: {value: notificationData.paidStartedNotifications ?: false, cfsqltype: "cf_sql_bit"},
            paidCanceledNotifications: {value: notificationData.paidCanceledNotifications ?: false, cfsqltype: "cf_sql_bit"},
            recommendationNotifications: {value: notificationData.recommendationNotifications ?: false, cfsqltype: "cf_sql_bit"},
            donationNotifications: {value: notificationData.donationNotifications ?: false, cfsqltype: "cf_sql_bit"},
            updatedAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
            updatedBy: {value: notificationData.userId, cfsqltype: "cf_sql_varchar"},
            userId: {value: notificationData.userId, cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"});
        
        return {
            success: true,
            message: "Notification preferences updated successfully"
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error updating notifications: " & e.message
        };
    }
}

/**
 * Update social media links
 */
function updateSocialLinks(struct socialData) {
    try {
        if (!structKeyExists(socialData, "userId")) {
            return {success: false, message: "User ID is required"};
        }
        
        // Update social media links
        queryExecute("
            UPDATE users SET
                facebook = :facebook,
                twitter = :twitter,
                threads = :threads,
                bluesky = :bluesky,
                linkedin = :linkedin,
                instagram = :instagram,
                youtube = :youtube,
                tiktok = :tiktok,
                mastodon = :mastodon,
                updated_at = :updatedAt,
                updated_by = :updatedBy
            WHERE id = :userId
        ", {
            facebook: {value: trim(socialData.facebook ?: ""), cfsqltype: "cf_sql_varchar"},
            twitter: {value: trim(socialData.twitter ?: ""), cfsqltype: "cf_sql_varchar"},
            threads: {value: trim(socialData.threads ?: ""), cfsqltype: "cf_sql_varchar"},
            bluesky: {value: trim(socialData.bluesky ?: ""), cfsqltype: "cf_sql_varchar"},
            linkedin: {value: trim(socialData.linkedin ?: ""), cfsqltype: "cf_sql_varchar"},
            instagram: {value: trim(socialData.instagram ?: ""), cfsqltype: "cf_sql_varchar"},
            youtube: {value: trim(socialData.youtube ?: ""), cfsqltype: "cf_sql_varchar"},
            tiktok: {value: trim(socialData.tiktok ?: ""), cfsqltype: "cf_sql_varchar"},
            mastodon: {value: trim(socialData.mastodon ?: ""), cfsqltype: "cf_sql_varchar"},
            updatedAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
            updatedBy: {value: socialData.userId, cfsqltype: "cf_sql_varchar"},
            userId: {value: socialData.userId, cfsqltype: "cf_sql_varchar"}
        }, {datasource: "blog"});
        
        return {
            success: true,
            message: "Social links updated successfully"
        };
        
    } catch (any e) {
        return {
            success: false,
            message: "Error updating social links: " & e.message
        };
    }
}

// Main request handling
response = {success: false, message: "Invalid request"};

if (cgi.request_method == "POST") {
    
    // Get current user ID from session
    if (structKeyExists(session, "userId") and len(session.userId)) {
        currentUserId = session.userId;
    } else {
        response = {success: false, message: "User not logged in"};
        writeOutput(serializeJSON(response));
        abort;
    }
    
    if (structKeyExists(variables, "currentUserId")) {
        if (structKeyExists(form, "action")) {
            
            switch (form.action) {
                case "updateProfile":
                    // Update basic profile information
                    userData = {
                        userId: currentUserId,
                        name: form.name ?: "",
                        email: form.email ?: "",
                        slug: form.slug ?: "",
                        bio: form.bio ?: "",
                        location: form.location ?: "",
                        website: form.website ?: "",
                        facebook: form.facebook ?: "",
                        twitter: form.twitter ?: ""
                    };
                    response = updateUserProfile(userData);
                    break;
                    
                case "updateNotifications":
                    // Update notification preferences
                    notificationData = {
                        userId: currentUserId,
                        commentNotifications: structKeyExists(form, "commentNotifications"),
                        mentionNotifications: structKeyExists(form, "mentionNotifications"),
                        milestoneNotifications: structKeyExists(form, "milestoneNotifications"),
                        freeSignupNotifications: structKeyExists(form, "freeSignupNotifications"),
                        paidStartedNotifications: structKeyExists(form, "paidStartedNotifications"),
                        paidCanceledNotifications: structKeyExists(form, "paidCanceledNotifications"),
                        recommendationNotifications: structKeyExists(form, "recommendationNotifications"),
                        donationNotifications: structKeyExists(form, "donationNotifications")
                    };
                    response = updateNotificationPreferences(notificationData);
                    break;
                    
                case "updatePassword":
                    // Update password
                    if (!structKeyExists(form, "currentPassword") || !structKeyExists(form, "newPassword")) {
                        response = {success: false, message: "Current and new passwords are required"};
                    } else if (len(form.newPassword) < 8) {
                        response = {success: false, message: "Password must be at least 8 characters"};
                    } else {
                        // In a real implementation, we would verify the current password first
                        // For now, just update the password
                        try {
                            queryExecute("
                                UPDATE users SET 
                                    password = :password,
                                    updated_at = :updatedAt,
                                    updated_by = :updatedBy
                                WHERE id = :userId
                            ", {
                                password: {value: hash(form.newPassword, "SHA-256"), cfsqltype: "cf_sql_varchar"},
                                updatedAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
                                updatedBy: {value: currentUserId, cfsqltype: "cf_sql_varchar"},
                                userId: {value: currentUserId, cfsqltype: "cf_sql_varchar"}
                            }, {datasource: "blog"});
                            
                            response = {success: true, message: "Password updated successfully"};
                        } catch (any e) {
                            response = {success: false, message: "Error updating password: " & e.message};
                        }
                    }
                    break;
                    
                case "updateSocial":
                    // Update social media links
                    socialData = {
                        userId: currentUserId,
                        facebook: form.facebook ?: "",
                        twitter: form.twitter ?: "",
                        threads: form.threads ?: "",
                        bluesky: form.bluesky ?: "",
                        linkedin: form.linkedin ?: "",
                        instagram: form.instagram ?: "",
                        youtube: form.youtube ?: "",
                        tiktok: form.tiktok ?: "",
                        mastodon: form.mastodon ?: ""
                    };
                    response = updateSocialLinks(socialData);
                    break;
                    
                case "removeAvatar":
                    // Remove profile image
                    try {
                        queryExecute("
                            UPDATE users 
                            SET profile_image = NULL,
                                updated_at = :updatedAt,
                                updated_by = :updatedBy
                            WHERE id = :userId
                        ", {
                            updatedAt: {value: now(), cfsqltype: "cf_sql_timestamp"},
                            updatedBy: {value: currentUserId, cfsqltype: "cf_sql_varchar"},
                            userId: {value: currentUserId, cfsqltype: "cf_sql_varchar"}
                        }, {datasource: "blog"});
                        
                        response = {success: true, message: "Profile image removed successfully"};
                    } catch (any e) {
                        response = {success: false, message: "Error removing profile image: " & e.message};
                    }
                    break;
                    
                default:
                    response = {success: false, message: "Unknown action"};
            }
            
        } else {
            response = {success: false, message: "No action specified"};
        }
    }
}

// Output JSON response
writeOutput(serializeJSON(response));
</cfscript>