#!/bin/bash

# 用于运行测试并自动重定向日志的脚本
# 用法: ./claude/scripts/test-and-log.sh path/to/test.py [optional_log_name.log]

if [ $# -eq 0 ]; then
    echo "用法: $0 <test_file_path> [log_filename]"
    echo "示例: $0 tests/e2e/my_test_name.py"
    echo "示例: $0 tests/e2e/my_test_name.py my_test_name_v2.log"
    exit 1
fi

TEST_PATH="$1"

# 如果不存在则创建 logs 目录
mkdir -p tests/logs

# 确定日志文件名
if [ $# -ge 2 ]; then
    # 使用提供的日志文件名（第二个参数）
    LOG_NAME="$2"
    # 确保以 .log 结尾
    if [[ ! "$LOG_NAME" == *.log ]]; then
        LOG_NAME="${LOG_NAME}.log"
    fi
    LOG_FILE="tests/logs/${LOG_NAME}"
else
    # 提取不带扩展名的测试文件名作为日志名
    TEST_NAME=$(basename "$TEST_PATH" .py)
    LOG_FILE="tests/logs/${TEST_NAME}.log"
fi

# 运行测试并重定向输出
echo "运行测试: $TEST_PATH"
echo "记录到: $LOG_FILE"
python "$TEST_PATH" > "$LOG_FILE" 2>&1

# 检查退出码
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ 测试成功完成。日志保存到 $LOG_FILE"
else
    echo "❌ 测试失败，退出码 $EXIT_CODE。检查 $LOG_FILE 获取详细信息"
fi

exit $EXIT_CODE