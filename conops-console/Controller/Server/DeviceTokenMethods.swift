import Foundation

extension ConopsServerClient {

    func registerDeviceToken(
        shortName: String,
        token: String,
        platform: String,
        deviceName: String?
    ) async -> Result<String, ServerError> {
        let request = DeviceTokenRegistrationRequest(
            deviceToken: token,
            platform: platform,
            deviceName: deviceName
        )

        return await sendData(
            "device-tokens/\(shortName)",
            method: .post,
            body: request,
            dtoType: String.self,
            returnType: String.self
        ) { $0 }
    }

    func unregisterDeviceToken(
        shortName: String,
        token: String
    ) async -> Result<String, ServerError> {
        let request = DeviceTokenUnregistrationRequest(deviceToken: token)

        return await sendData(
            "device-tokens/\(shortName)",
            method: .delete,
            body: request,
            dtoType: String.self,
            returnType: String.self
        ) { $0 }
    }
}
