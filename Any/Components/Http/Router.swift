
import Foundation

enum Router: String {
    
    //    static let BASE_SERVICE_URL = "https://techimmense.in/AnyNew/webservice/"
    //    static let BASE_IMAGE_URL = "https://techimmense.in/AnyNew/uploads/images/"
    
    static let BASE_SERVICE_URL = "http://52.220.103.59/Any/webservice/"
    static let BASE_IMAGE_URL = "http://52.220.103.59/Any/uploads/images/"
    
    case logIn
    case signUp
    case client_signup
    case verify_number
    case worker_signup
    case update_profile_worker
    case update_profile_client
    case get_set_shift_book
    case delete_my_shifts
    case get_shift_complete_by_worker
    case get_client_list
    case get_shift_by_day
    case get_set_shift_cart
    case get_job_type
    case set_shift
    case get_broadcast_shift
    case get_client_weekly_rate
    case update_my_shifts
    case get_set_shift_book_by_date
    case get_OutletAdmin_AuthrisedApprover
    case change_set_shift_status
    case get_set_shift_book_client_side
    case add_client_date_wise_open_close
    case delete_OutletAdmin_AuthrisedApprover
    case add_OutletAdmin_AuthrisedApprover
    case get_my_set_shift
    case get_shift_complete_by_client
    case add_client_weekly_rate
    case update_booking_status_profile
    case get_shift_by_day_week_count
    case add_to_set_shift_cart
    case add_set_shift_book
    case get_set_shift_cart_details
    case add_clock_in_time
    case add_break_time
    case change_set_shift_status_worker_side
    case get_notification_count
    case add_to_set_shift_cart_broadcast
    case shift_rejected_by_worker
    case get_days_List
    case delete_set_shift_cart
    case get_client_shift_by_date
    case get_client_date_rate
    case get_set_shift_details
    case get_worker_list_by_jobtype
    case get_Outlet
    
    case delete_client_date_rate
    case add_client_date_rate
    case update_client_date_rate
    
    case resendotp
    case forgot_password
    case get_profile
    case update_profile
    case get_banner_list
    case vehicle_list
    case get_nearest_driver
    case get_user_request
    case get_conversation_detail
    case get_chat_detail
    case get_notification_list
    case reset_password
    
    case change_password
    case otp_call
    case get_user_page
    case get_rating_review
    case request_nearbuy_driver
    case user_cancel_request
    case get_request_details
    case offer_accept_by_user
    case mobile_verify
    case country_list
    case insert_chat
    case add_employee_rating_review
    case save_CardStripe
    case create_Customer
    case retrieve_all_card_stripe
    case delete_SaveCard
    
    case update_request_payment_type
    
    case delete_Account
    
    case get_shift_by_10day_count
    case get_country_list
    case get_country_details
    case like_unlike
    case get_fav_client_list
    case worker_update_document
    
    case set_shift_autoapproval_status
    case add_user_rating_review
    
    case delete_Outlet
    case add_UpdateOutlet
    
    public func url() -> String {
        switch self {
        case .logIn:
            return Router.oAuthRoute(path: "login?")
        case .signUp:
            return Router.oAuthRoute(path: "signup?")
        case .client_signup:
            return Router.oAuthRoute(path: "client_signup?")
        case .verify_number:
            return Router.oAuthRoute(path: "verify_number?")
        case .worker_signup:
            return Router.oAuthRoute(path: "worker_signup?")
        case .update_profile_worker:
            return Router.oAuthRoute(path: "update_profile_worker?")
        case .update_profile_client:
            return Router.oAuthRoute(path: "update_profile_client?")
        case .get_set_shift_book:
            return Router.oAuthRoute(path: "get_set_shift_book?")
        case .delete_my_shifts:
            return Router.oAuthRoute(path: "delete_my_shifts?")
        case .get_shift_complete_by_worker:
            return Router.oAuthRoute(path: "get_shift_complete_by_worker?")
        case .get_client_list:
            return Router.oAuthRoute(path: "get_client_list?")
        case .get_shift_by_day:
            return Router.oAuthRoute(path: "get_shift_by_day?")
        case .get_set_shift_cart:
            return Router.oAuthRoute(path: "get_set_shift_cart?")
        case .get_job_type:
            return Router.oAuthRoute(path: "get_job_type?")
            
        case .set_shift:
            return Router.oAuthRoute(path: "set_shift?")
            
        case .get_broadcast_shift:
            return Router.oAuthRoute(path: "get_broadcast_shift?")
        case .get_client_weekly_rate:
            return Router.oAuthRoute(path: "get_client_weekly_rate?")
        case .update_my_shifts:
            return Router.oAuthRoute(path: "update_my_shifts?")
        case .get_set_shift_book_by_date:
            return Router.oAuthRoute(path: "get_set_shift_book_by_date?")
        case .get_OutletAdmin_AuthrisedApprover:
            return Router.oAuthRoute(path: "get_OutletAdmin_AuthrisedApprover?")
        case .change_set_shift_status:
            return Router.oAuthRoute(path: "change_set_shift_status?")
        case .get_set_shift_book_client_side:
            return Router.oAuthRoute(path: "get_set_shift_book_client_side_new?")
        case .get_client_shift_by_date:
            return Router.oAuthRoute(path: "get_client_shift_by_date?")
        case .get_client_date_rate:
            return Router.oAuthRoute(path: "get_client_date_rate")
            
            //        case .get_set_shift_book_client_side:
            //            return Router.oAuthRoute(path: "get_set_shift_book_client_side?")
            
        case .add_client_date_wise_open_close:
            return Router.oAuthRoute(path: "add_client_date_wise_open_close?")
        case .delete_OutletAdmin_AuthrisedApprover:
            return Router.oAuthRoute(path: "delete_OutletAdmin_AuthrisedApprover?")
        case .add_OutletAdmin_AuthrisedApprover:
            return Router.oAuthRoute(path: "add_OutletAdmin_AuthrisedApprover?")
        case .get_my_set_shift:
            return Router.oAuthRoute(path: "get_my_set_shift?")
        case .get_shift_complete_by_client:
            return Router.oAuthRoute(path: "get_shift_complete_by_client?")
        case .add_client_weekly_rate:
            return Router.oAuthRoute(path: "add_client_weekly_rate?")
        case .update_booking_status_profile:
            return Router.oAuthRoute(path: "update_booking_status_profile?")
        case .get_shift_by_day_week_count:
            return Router.oAuthRoute(path: "get_shift_by_day_week_count?")
        case .add_to_set_shift_cart:
            return Router.oAuthRoute(path: "add_to_set_shift_cart?")
        case .add_set_shift_book:
            return Router.oAuthRoute(path: "add_set_shift_book?")
        case .get_set_shift_cart_details:
            return Router.oAuthRoute(path: "get_set_shift_cart_details?")
        case .add_clock_in_time:
            return Router.oAuthRoute(path: "add_clock_in_time?")
        case .add_break_time:
            return Router.oAuthRoute(path: "add_break_time?")
        case .change_set_shift_status_worker_side:
            return Router.oAuthRoute(path: "change_set_shift_status_worker_side?")
        case .get_notification_count:
            return Router.oAuthRoute(path: "get_notification_count?")
        case .add_to_set_shift_cart_broadcast:
            return Router.oAuthRoute(path: "add_to_set_shift_cart_broadcast?")
        case .shift_rejected_by_worker:
            return Router.oAuthRoute(path: "shift_rejected_by_worker?")
        case .delete_set_shift_cart:
            return Router.oAuthRoute(path: "delete_set_shift_cart?")
            
        case .resendotp:
            return Router.oAuthRoute(path: "resendotp?")
        case .forgot_password:
            return Router.oAuthRoute(path: "forgot_password?")
        case .get_profile:
            return Router.oAuthRoute(path: "get_profile?")
        case .update_profile:
            return Router.oAuthRoute(path: "user_update_profile?")
        case .get_banner_list:
            return Router.oAuthRoute(path: "get_banner_list?")
        case .vehicle_list:
            return Router.oAuthRoute(path: "vehicle_list?")
        case .get_nearest_driver:
            return Router.oAuthRoute(path: "get_nearest_driver?")
        case .get_user_request:
            return Router.oAuthRoute(path: "get_user_request?")
        case .get_conversation_detail:
            return Router.oAuthRoute(path: "get_conversation_detail?")
        case .get_chat_detail:
            return Router.oAuthRoute(path: "get_chat_detail?")
        case .get_notification_list:
            return Router.oAuthRoute(path: "get_notification_list?")
        case .change_password:
            return Router.oAuthRoute(path: "change_password?")
        case .otp_call:
            return Router.oAuthRoute(path: "otp_call?")
        case .get_user_page:
            return Router.oAuthRoute(path: "get_user_page?")
        case .get_rating_review:
            return Router.oAuthRoute(path: "get_rating_review?")
        case .request_nearbuy_driver:
            return Router.oAuthRoute(path: "request_nearbuy_driver?")
        case .user_cancel_request:
            return Router.oAuthRoute(path: "user_cancel_request?")
        case .get_request_details:
            return Router.oAuthRoute(path: "get_request_details?")
        case .offer_accept_by_user:
            return Router.oAuthRoute(path: "offer_accept_by_user?")
        case .mobile_verify:
            return Router.oAuthRoute(path: "mobile_verify?")
        case .country_list:
            return Router.oAuthRoute(path: "country_list?")
        case .insert_chat:
            return Router.oAuthRoute(path: "insert_chat?")
        case .add_employee_rating_review:
            return Router.oAuthRoute(path: "add_employee_rating_review?")
            
        case .get_days_List:
            return Router.oAuthRoute(path: "get_next_seven_date_list?")
            
        case .save_CardStripe:
            return Router.oAuthRoute(path: "save_card_stripe?")
        case .create_Customer:
            return Router.oAuthRoute(path: "create_customer?")
        case .retrieve_all_card_stripe:
            return Router.oAuthRoute(path: "retrieve_all_card_stripe?")
        case .delete_SaveCard:
            return Router.oAuthRoute(path: "delete_saved_card?")
            
        case .get_set_shift_details:
            return Router.oAuthRoute(path: "get_set_shift_details?")
        case .get_worker_list_by_jobtype:
            return Router.oAuthRoute(path: "get_worker_list_by_jobtype?")
            
        case .delete_client_date_rate:
            return Router.oAuthRoute(path: "delete_client_date_rate?")
        case .reset_password:
            return Router.oAuthRoute(path: "reset_password?")
            
        case .add_client_date_rate:
            return Router.oAuthRoute(path: "add_client_date_rate")
        case .update_client_date_rate:
            return Router.oAuthRoute(path: "update_client_date_rate?")
            
        case .update_request_payment_type:
            return Router.oAuthRoute(path: "update_request_payment_type?")
            
        case .delete_Account:
            return Router.oAuthRoute(path: "delete_Account?")
            
        case .get_shift_by_10day_count:
            return Router.oAuthRoute(path: "get_shift_by_10day_count?")
            
        case .get_country_list:
            return Router.oAuthRoute(path: "get_country_list?")
            
        case .get_country_details:
            return Router.oAuthRoute(path: "get_country_details?")
            
        case .like_unlike:
            return Router.oAuthRoute(path: "like_unlike?")
        case .get_fav_client_list:
            return Router.oAuthRoute(path: "get_fav_client_list?")
        case .worker_update_document:
            return Router.oAuthRoute(path: "worker_update_document?")
            
        case .set_shift_autoapproval_status:
            return Router.oAuthRoute(path: "set_shift_autoapproval_status?")
            
        case .add_user_rating_review:
            return Router.oAuthRoute(path: "add_user_rating_review?")
            
        case .get_Outlet:
            return Router.oAuthRoute(path: "get_Outlet?")
            
        case .add_UpdateOutlet:
            if isComeOutlet {
                return Router.oAuthRoute(path: "update_Outlet?")
            } else {
                return Router.oAuthRoute(path: "add_Outlet?")
            }
            
        case .delete_Outlet:
            return Router.oAuthRoute(path: "delete_Outlet?")
            
        }
    }
    
    private static func oAuthRoute(path: String) -> String {
        return Router.BASE_SERVICE_URL + path
    }
    
}

//
//    @GET("update_close_status?")
//    Call<ResponseBody> setWeeklyOpenCLose(@Query("user_id") String user_id,@Query("day_name") String day_name,@Query("close_status") String close_status);
////
//
//    //https://techimmense.in/Any/webservice/get_my_set_shift?user_id=3
//    @GET("get_my_set_shift?")
//    Call<ResponseBody> getMyShifts(@Query("user_id") String user_id,@Query("shift_type") String shift_type);
//
//
//    //http://techimmense.in/Any/webservice/get_set_shift_details?set_shift_id=1
//    @GET("get_set_shift_details?")
//    Call<ResponseBody> getMyShiftDetails(@Query("set_shift_id") String set_shift_id);
//
//    @GET("shift_rejected_by_worker?")
//    Call<ResponseBody> declineByWorker(@Query("worker_id") String worker_id,@Query("shift_id") String shift_id);
//
//    @GET("shift_accepted_by_worker?")
//    Call<ResponseBody> acceptedByWorker(@Query("worker_id") String worker_id,@Query("shift_id") String shift_id);
//
////
//
//    @GET("change_request_status?")
//    Call<ResponseBody> changeStatusofBooking(@Query("request_id") String request_id,@Query("provider_id") String provider_id,@Query("user_id") String user_id,@Query("status") String status,@Query("reason_title") String reason_title,@Query("reason_detail") String reason_detail,@Query("cancelation_fee") String cancelation_fee);
//
//
//    @GET("add_to_set_shift_cart_broadcast?")
//    Call<ResponseBody> acceptByWorker(@Query("user_id") String user_id,@Query("client_id") String client_id,@Query("shift_id") String shift_id,@Query("day_name") String day_name,@Query("date") String date);
//
//
//    @GET("change_set_shift_status_worker_side?")
//    Call<ResponseBody> cancelRequestByUserInHome(@Query("cart_id") String cart_id,@Query("status") String status);
//
//
//
//  //https://techimmense.in/Any/webservice/get_set_shift_cart_details?cart_id=8
//    @GET("get_set_shift_cart_details?")
//    Call<ResponseBody> getJobDetails(@Query("user_id") String user_id,@Query("cart_id") String cart_id);
//
//    @GET("update_booking_status_profile?")
//    Call<ResponseBody> updateOpenCLoseSts(@Query("user_id") String user_id,@Query("booking_status") String booking_status);
//
//
//    //https://techimmense.in/Any/webservice/get_notification_count?user_id=1
//    @GET("get_notification_count?")
//    Call<ResponseBody> getNotificationCounts(@Query("user_id") String userID);
//
//    //
//    @GET("get_next_seven_date_list?")
//    Call<ResponseBody> getSevenDays(@Query("user_id") String user_id);
//
