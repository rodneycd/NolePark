// test-api.ts
import authApi from "../src/api/auth";
import userApi from "../src/api/users";

async function runTestSuite() {
    console.log("🚀 Starting NolePark API Integration Test...\n");

    try {
        // Test 1: Authentication
        console.log("Step 1: Testing Login...");
        const loginRes = await authApi.login({
            email: 'sthompson@parking.fsu.edu',
            password: 'admin_pass_1'
        });

        if (loginRes.success) {
            console.log(`✅ Login Success! User ID: ${loginRes.user_id}`);

            // Test 2: Fetch Specific Profile
            console.log("\nStep 2: Testing Single Profile Fetch...");
            const profile = await userApi.getUserProfile(loginRes.user_id);
            console.log(`✅ Profile Received:`, {
                Name: profile.name,
                Role: profile.user_role,
                FSUID: profile.fsuid || "N/A"
            });

            // Test 3: Fetch All Profiles (Admin privilege check)
            console.log("\nStep 3: Testing All Profiles Fetch...");
            const allUsers = await userApi.getAllUsers();
            console.log(`✅ Received ${allUsers.length} total user profiles.`);
            
        } else {
            console.error("❌ Login failed at the logic level.");
        }

    } catch (error) {
        console.error("🛑 Test Suite Crashed!");
        console.error(error);
    }
}

runTestSuite();