-- Supabase数据库初始化脚本
-- 浙江旅游搭子应用数据库结构

-- 用户资料表
CREATE TABLE IF NOT EXISTS user_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    avatar TEXT DEFAULT 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=100&h=100&fit=crop&crop=face',
    age INTEGER,
    gender TEXT CHECK (gender IN ('男', '女', '其他')),
    location TEXT,
    interests TEXT[] DEFAULT '{}',
    travel_style TEXT CHECK (travel_style IN ('休闲', '冒险', '文化', '美食', '购物')),
    rating DECIMAL(2,1) DEFAULT 4.5,
    trips_count INTEGER DEFAULT 0,
    bio TEXT DEFAULT '这个人很懒，还没有写个人简介',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 行程表
CREATE TABLE IF NOT EXISTS trips (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    destination TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    people_count INTEGER DEFAULT 2,
    budget INTEGER DEFAULT 2000,
    description TEXT,
    requirements TEXT,
    status TEXT DEFAULT '招募中' CHECK (status IN ('招募中', '进行中', '已完成', '已取消')),
    creator_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 匹配表
CREATE TABLE IF NOT EXISTS matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    matched_user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    UNIQUE(user_id, matched_user_id, trip_id)
);

-- 景点表
CREATE TABLE IF NOT EXISTS attractions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    city TEXT NOT NULL,
    type TEXT NOT NULL,
    duration TEXT,
    price TEXT,
    rating DECIMAL(2,1) DEFAULT 4.0,
    image TEXT,
    description TEXT,
    best_time TEXT,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 酒店表
CREATE TABLE IF NOT EXISTS hotels (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    city TEXT NOT NULL,
    rating DECIMAL(2,1) DEFAULT 4.0,
    price INTEGER NOT NULL,
    image TEXT,
    features TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 餐厅表
CREATE TABLE IF NOT EXISTS restaurants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    city TEXT NOT NULL,
    cuisine TEXT NOT NULL,
    rating DECIMAL(2,1) DEFAULT 4.0,
    price INTEGER NOT NULL,
    image TEXT,
    signature TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 行程计划表
CREATE TABLE IF NOT EXISTS trip_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    day INTEGER NOT NULL,
    date DATE NOT NULL,
    activities JSONB NOT NULL DEFAULT '[]',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 消息表
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 评论表
CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    target_user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- 创建索引优化查询
CREATE INDEX idx_trips_creator_id ON trips(creator_id);
CREATE INDEX idx_trips_destination ON trips(destination);
CREATE INDEX idx_trips_status ON trips(status);
CREATE INDEX idx_matches_user_id ON matches(user_id);
CREATE INDEX idx_matches_matched_user_id ON matches(matched_user_id);
CREATE INDEX idx_matches_status ON matches(status);
CREATE INDEX idx_attractions_city ON attractions(city);
CREATE INDEX idx_attractions_type ON attractions(type);
CREATE INDEX idx_messages_sender_id ON messages(sender_id);
CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
CREATE INDEX idx_reviews_user_id ON reviews(user_id);
CREATE INDEX idx_reviews_target_user_id ON reviews(target_user_id);

-- 创建触发器自动更新时间戳
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_trips_updated_at BEFORE UPDATE ON trips
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_matches_updated_at BEFORE UPDATE ON matches
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 插入示例数据 - 用户
INSERT INTO user_profiles (email, name, age, gender, location, interests, travel_style, rating, trips_count, bio) VALUES
('xiaoyu@example.com', '小雨', 25, '女', '杭州', ARRAY['摄影', '美食', '徒步'], '休闲', 4.8, 12, '喜欢拍照和探索美食，希望找到志同道合的旅伴'),
('aming@example.com', '阿明', 28, '男', '宁波', ARRAY['登山', '露营', '户外'], '冒险', 4.9, 8, '户外运动爱好者，寻找一起挑战自我的伙伴'),
('xiaofang@example.com', '小芳', 23, '女', '绍兴', ARRAY['文艺', '古镇', '品茶'], '文化', 4.7, 15, '热爱传统文化，喜欢慢节奏的旅行'),
('xiaogang@example.com', '小刚', 30, '男', '温州', ARRAY['历史', '博物馆', '古建筑'], '文化', 4.6, 20, '历史文化爱好者，走遍浙江的古迹');

-- 插入示例数据 - 景点
INSERT INTO attractions (name, city, type, duration, price, rating, image, description, best_time, tags) VALUES
('西湖', '杭州', '自然风光', '4-6小时', '免费', 4.9, 'https://images.unsplash.com/photo-1598887142487-2e7829cda8c0?w=300&h=200&fit=crop', '杭州标志性景点，湖光山色美不胜收', '春秋两季', ARRAY['拍照', '游船', '断桥']),
('千岛湖', '淳安', '自然风光', '1-2天', '130元', 4.8, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&h=200&fit=crop', '1078个岛屿组成的美丽湖泊', '4-10月', ARRAY['游船', '钓鱼', '度假村']),
('普陀山', '舟山', '宗教文化', '1-2天', '160元', 4.7, 'https://images.unsplash.com/photo-1593532847206-e8bc3d633ae7?w=300&h=200&fit=crop', '观音菩萨道场，佛教圣地', '全年', ARRAY['佛教', '海岛', '祈福']),
('乌镇', '桐乡', '古镇', '1天', '150元', 4.6, 'https://images.unsplash.com/photo-1595841696677-6489ff3f8cd1?w=300&h=200&fit=crop', '江南六大古镇之一，水乡风情', '春秋两季', ARRAY['古镇', '水乡', '文化']),
('雁荡山', '温州', '自然风光', '1-2天', '200元', 4.5, 'https://images.unsplash.com/photo-1540979388789-6cee28b1eda9?w=300&h=200&fit=crop', '以奇峰怪石著称的名山', '4-11月', ARRAY['登山', '奇石', '瀑布']),
('西塘古镇', '嘉善', '古镇', '1天', '95元', 4.4, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&h=200&fit=crop', '保存完好的江南水乡古镇', '春秋两季', ARRAY['古镇', '夜景', '酒吧']);

-- 插入示例数据 - 酒店
INSERT INTO hotels (name, location, city, rating, price, image, features) VALUES
('杭州西湖国宾馆', '杭州西湖区', '杭州', 4.8, 880, 'https://images.unsplash.com/photo-1561501900-3701fa6a0864?w=300&h=200&fit=crop', ARRAY['湖景房', '免费早餐', 'SPA']),
('千岛湖洲际度假酒店', '淳安千岛湖', '淳安', 4.9, 1200, 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=300&h=200&fit=crop', ARRAY['湖景房', '私人沙滩', '儿童乐园']),
('乌镇民宿', '桐乡乌镇', '桐乡', 4.5, 380, 'https://images.unsplash.com/photo-1595841696677-6489ff3f8cd1?w=300&h=200&fit=crop', ARRAY['古镇风情', '临水而建', '传统建筑']);

-- 插入示例数据 - 餐厅
INSERT INTO restaurants (name, location, city, cuisine, rating, price, image, signature) VALUES
('楼外楼', '杭州西湖区', '杭州', '杭帮菜', 4.7, 150, 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=300&h=200&fit=crop', '西湖醋鱼、东坡肉'),
('知味观', '杭州', '杭州', '杭帮菜', 4.5, 80, 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=300&h=200&fit=crop', '小笼包、猫耳朵'),
('千岛湖鱼头', '淳安', '淳安', '农家菜', 4.6, 120, 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=300&h=200&fit=crop', '千岛湖鱼头汤');

-- 启用实时功能
ALTER TABLE trips REPLICA IDENTITY FULL;
ALTER TABLE matches REPLICA IDENTITY FULL;
ALTER TABLE messages REPLICA IDENTITY FULL;