//  Copyright © 2022 Optimove. All rights reserved.

import Foundation

enum OptimobileUserDefaultsKey: String {
    case CREDENTIALS_JSON = "KumulosCredentialsJson"
    case BASE_URLS = "KumulosEventsBaseUrls"
    case REGION = "KumulosEventsRegion"
    case MEDIA_BASE_URL = "KumulosMediaBaseUrl"
    case IAR_BASE_URL = "KumulosIARBaseUrl"
    case INSTALL_UUID = "KumulosUUID"
    case USER_ID = "KumulosCurrentUserID"
    case BADGE_COUNT = "KumulosBadgeCount"
    case PENDING_NOTIFICATIONS = "KumulosPendingNotifications"

    // exist only in standard defaults for app
    case MIGRATED_TO_GROUPS = "KumulosDidMigrateToAppGroups"
    case IN_APP_LAST_SYNCED_AT = "KumulosMessagesLastSyncedAt"
    case IN_APP_MOST_RECENT_UPDATED_AT = "KumulosInAppMostRecentUpdatedAt"
    case IN_APP_CONSENTED = "KumulosInAppConsented"

    // exist only in standard defaults for extension
    case DYNAMIC_CATEGORY = "__kumulos__dynamic__categories__"

    static let sharedKeys = [
        MEDIA_BASE_URL,
        INSTALL_UUID,
        USER_ID,
        BADGE_COUNT,
        PENDING_NOTIFICATIONS,
    ]
}
