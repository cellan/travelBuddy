// 浙里游 - 主要JavaScript逻辑
// 版本: 1.0.0

// 全局变量和配置
const CONFIG = {
    APP_NAME: '浙里游',
    VERSION: '1.0.0',
    PRIMARY_COLOR: '#4CD1C4'
};

// 工具函数
const Utils = {
    // 显示通知
    showNotification: (message, type = 'info', duration = 3000) => {
        const notification = document.createElement('div');
        notification.className = `fixed top-20 left-1/2 transform -translate-x-1/2 z-50 px-4 py-2 rounded-lg text-white text-sm ${
            type === 'success' ? 'bg-green-500' : 
            type === 'error' ? 'bg-red-500' : 'bg-blue-500'
        }`;
        notification.textContent = message;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            notification.remove();
        }, duration);
    }
};

// 应用初始化
const App = {
    init: function() {
        console.log(`${CONFIG.APP_NAME} v${CONFIG.VERSION} 初始化中...`);
        
        // 检查浏览器兼容性
        if (!this.checkBrowserCompatibility()) {
            Utils.showNotification('您的浏览器版本过低，请升级后使用', 'error');
            return;
        }
        
        // 初始化页面特定功能
        this.initPageSpecific();
        
        console.log('应用初始化完成');
    },

    checkBrowserCompatibility: function() {
        return window.localStorage && window.JSON && document.querySelector;
    },

    initPageSpecific: function() {
        const path = window.location.pathname;
        const page = path.split('/').pop().replace('.html', '') || 'index';
        
        switch (page) {
            case 'index':
                this.initIndexPage();
                break;
            case 'match':
                this.initMatchPage();
                break;
            case 'ai-assistant':
                this.initAIAssistantPage();
                break;
            case 'profile':
                this.initProfilePage();
                break;
        }
    },

    initIndexPage: function() {
        console.log('初始化首页...');
        
        // 初始化轮播
        this.initCarousel();
        
        // 绑定全局事件
        this.bindGlobalEvents();
    },

    initCarousel: function() {
        if (typeof Splide !== 'undefined') {
            try {
                new Splide('#destination-splide', {
                    type: 'loop',
                    perPage: 1,
                    perMove: 1,
                    gap: '1rem',
                    padding: '2rem',
                    arrows: false,
                    pagination: true,
                    autoplay: true,
                    interval: 4000
                }).mount();
                console.log('轮播初始化成功');
            } catch (error) {
                console.error('轮播初始化失败:', error);
            }
        }
    },

    bindGlobalEvents: function() {
        // 错误处理
        window.addEventListener('error', (e) => {
            console.error('全局错误:', e.error);
            Utils.showNotification('应用出现错误，请刷新页面重试', 'error');
        });
    },

    initMatchPage: function() {
        console.log('初始化匹配页面...');
    },

    initAIAssistantPage: function() {
        console.log('初始化AI助手页面...');
    },

    initProfilePage: function() {
        console.log('初始化个人中心页面...');
    }
};

// 页面加载完成后初始化应用
document.addEventListener('DOMContentLoaded', function() {
    try {
        App.init();
    } catch (error) {
        console.error('应用初始化失败:', error);
        Utils.showNotification('应用初始化失败，请刷新页面重试', 'error');
    }
});

// 全局错误处理
window.addEventListener('unhandledrejection', function(e) {
    console.error('未处理的Promise拒绝:', e.reason);
    Utils.showNotification('应用出现错误，请刷新页面重试', 'error');
});

// 导出到全局作用域
window.Utils = Utils;
window.CONFIG = CONFIG;