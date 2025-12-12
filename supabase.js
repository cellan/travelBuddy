// Supabase客户端配置
const SUPABASE_URL = 'https://your-project-ref.supabase.co';
const SUPABASE_ANON_KEY = 'your-anon-key-here';

// 创建Supabase客户端实例
const supabase = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// 用户认证相关函数
class AuthService {
    static async signUp(email, password, userData) {
        try {
            const { data, error } = await supabase.auth.signUp({
                email: email,
                password: password,
                options: {
                    data: userData
                }
            });
            
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('注册失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async signIn(email, password) {
        try {
            const { data, error } = await supabase.auth.signInWithPassword({
                email: email,
                password: password
            });
            
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('登录失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async signOut() {
        try {
            const { error } = await supabase.auth.signOut();
            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('登出失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getCurrentUser() {
        try {
            const { data: { user }, error } = await supabase.auth.getUser();
            if (error) throw error;
            return { success: true, user };
        } catch (error) {
            console.error('获取用户信息失败:', error);
            return { success: false, error: error.message };
        }
    }
}

// 用户数据相关函数
class UserService {
    static async createUserProfile(userData) {
        try {
            const { data, error } = await supabase
                .from('user_profiles')
                .insert([userData])
                .select()
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('创建用户资料失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getUserProfile(userId) {
        try {
            const { data, error } = await supabase
                .from('user_profiles')
                .select('*')
                .eq('id', userId)
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('获取用户资料失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async updateUserProfile(userId, updates) {
        try {
            const { data, error } = await supabase
                .from('user_profiles')
                .update(updates)
                .eq('id', userId)
                .select()
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('更新用户资料失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getAllUsers(excludeUserId = null) {
        try {
            let query = supabase
                .from('user_profiles')
                .select('*');
                
            if (excludeUserId) {
                query = query.neq('id', excludeUserId);
            }
            
            const { data, error } = await query;
            if (error) throw error;
            
            return { success: true, data };
        } catch (error) {
            console.error('获取用户列表失败:', error);
            return { success: false, error: error.message };
        }
    }
}

// 行程相关函数
class TripService {
    static async createTrip(tripData) {
        try {
            const { data, error } = await supabase
                .from('trips')
                .insert([tripData])
                .select()
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('创建行程失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getTripById(tripId) {
        try {
            const { data, error } = await supabase
                .from('trips')
                .select('*')
                .eq('id', tripId)
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('获取行程失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getUserTrips(userId) {
        try {
            const { data, error } = await supabase
                .from('trips')
                .select('*')
                .eq('creator_id', userId)
                .order('created_at', { ascending: false });
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('获取用户行程失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getAllTrips() {
        try {
            const { data, error } = await supabase
                .from('trips')
                .select('*')
                .order('created_at', { ascending: false });
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('获取所有行程失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async updateTrip(tripId, updates) {
        try {
            const { data, error } = await supabase
                .from('trips')
                .update(updates)
                .eq('id', tripId)
                .select()
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('更新行程失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async deleteTrip(tripId) {
        try {
            const { error } = await supabase
                .from('trips')
                .delete()
                .eq('id', tripId);
                
            if (error) throw error;
            return { success: true };
        } catch (error) {
            console.error('删除行程失败:', error);
            return { success: false, error: error.message };
        }
    }
}

// 匹配相关函数
class MatchService {
    static async createMatch(matchData) {
        try {
            const { data, error } = await supabase
                .from('matches')
                .insert([matchData])
                .select()
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('创建匹配失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getUserMatches(userId) {
        try {
            const { data, error } = await supabase
                .from('matches')
                .select('*')
                .or(`user_id.eq.${userId},matched_user_id.eq.${userId}`)
                .order('created_at', { ascending: false });
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('获取用户匹配失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async updateMatchStatus(matchId, status) {
        try {
            const { data, error } = await supabase
                .from('matches')
                .update({ status: status })
                .eq('id', matchId)
                .select()
                .single();
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('更新匹配状态失败:', error);
            return { success: false, error: error.message };
        }
    }
}

// 景点数据相关函数
class AttractionService {
    static async getAllAttractions() {
        try {
            const { data, error } = await supabase
                .from('attractions')
                .select('*')
                .order('rating', { ascending: false });
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('获取景点数据失败:', error);
            return { success: false, error: error.message };
        }
    }
    
    static async getAttractionsByCity(city) {
        try {
            const { data, error } = await supabase
                .from('attractions')
                .select('*')
                .eq('city', city)
                .order('rating', { ascending: false });
                
            if (error) throw error;
            return { success: true, data };
        } catch (error) {
            console.error('获取城市景点失败:', error);
            return { success: false, error: error.message };
        }
    }
}

// 实时订阅
class RealtimeService {
    static subscribeToTrips(callback) {
        return supabase
            .channel('trips-channel')
            .on('postgres_changes', 
                { event: '*', schema: 'public', table: 'trips' }, 
                callback
            )
            .subscribe();
    }
    
    static subscribeToMatches(userId, callback) {
        return supabase
            .channel('matches-channel')
            .on('postgres_changes', 
                { 
                    event: '*', 
                    schema: 'public', 
                    table: 'matches',
                    filter: `user_id=eq.${userId}`
                }, 
                callback
            )
            .subscribe();
    }
}

// 导出所有服务
window.SupabaseServices = {
    AuthService,
    UserService,
    TripService,
    MatchService,
    AttractionService,
    RealtimeService
};