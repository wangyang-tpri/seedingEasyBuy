<template>
    <div class="container">
    <view>
      <u-form
        labelPosition="left"
        :model="formData"
        ref="form"
        :borderBottom="true"
      >
        <u-form-item
          label="苗木名称"
          prop="vehicleNumber"
          borderBottom
        >
          <u--input
            v-model="formData.vehicleNumber"
            placeholder="请输入"
            border="none"
            inputAlign="right"
          />
        </u-form-item>
        <u-form-item label="苗木地址" prop="alarmLocation" borderBottom>
          <div  style="display: flex; width: 100%">
            <u--text
              :text="formData.alarmLocation || '请选择'"
              :color="formData.alarmLocation ? '#000' : '#ccc'"
              align="right"
            ></u--text>
            <u-icon
              slot="right"
              name="arrow-right"
              color="#ccc"
            ></u-icon>
          </div>
        </u-form-item>
        <u-form-item label="苗木直径" prop="alarmType" borderBottom>
          <u--input
            border="true"
            readonly
            inputAlign="right"
            placeholder="请选择"
          ></u--input>
        </u-form-item>
        <u-form-item label="苗木名称" prop="alarmPersonFullName" borderBottom>
          <div style="display: flex; width: 100%">
            <u--input
              placeholder="请选择"
              v-model="formData.alarmPersonFullName"
              inputAlign="right"
              border="none"
              readonly
            ></u--input>
            <u-icon
              slot="right"
              name="arrow-right"
              color="#ccc"
            ></u-icon>
          </div>
        </u-form-item>
        <u-form-item
          label="苗木图片"
          prop="vehicleName"
          borderBottom
        >
          <u--input
            v-model="formData.vehicleName"
            placeholder="请输入"
            border="none"
            inputAlign="right"
          />
        </u-form-item>
        <u-form-item
          label="记录人"
          prop="vehicleName"
          borderBottom
        >
          <u--input
            v-model="formData.vehicleName"
            placeholder="请输入"
            border="none"
            inputAlign="right"
          />
        </u-form-item>
        <u-form-item
          label="手机号"
          prop="vehicleName"
          borderBottom
        >
          <u--input
            v-model="formData.vehicleName"
            placeholder="请输入"
            border="none"
            inputAlign="right"
          />
        </u-form-item>
        <div class="item2">
          <div class="key">备注</div>
          <div class="textArea">
            <div class="boxAll">
              <div
                class="likeTextarea"
                @click="isShowTextarea = true"
                v-show="!isShowTextarea"
                :style="[
                  formData.remark
                    ? { color: '#606266' }
                    : { color: 'rgb(192,196,204)' },
                ]"
              >
                {{ formData.remark || "请输入" }}
              </div>
              <u--textarea
                :focus="isShowTextarea"
                @blur="isShowTextarea = false"
                v-if="isShowTextarea"
                v-model="formData.remark"
                confirmType="done"
                placeholder="请输入"
                height="100"
                maxlength="300"
              ></u--textarea>
            </div>
          </div>
        </div>
        <div style="margin-top: 80rpx">

            <u-button text="提交" type="primary"></u-button>
            <u-button text="重置" type="error" style="margin-top: 100rpx"></u-button>
        </div>
      </u-form>
    </view>
    </div>
  </template>
  
  <script>
  import { getFlowInstance } from "@/api/bpm";
  import jadeImageUpload from "@/components/jade-image-upload/jade-image-upload.vue";
  import uploadImage from "@/components/uploadImage";
  export default {
    components: { jadeImageUpload, uploadImage },
    data () {
      return {
        showTarget: false,
        showEvent: false,
        showTime: false,
        showUser: false,
        showEventGrade: false,
        minDate: Date.now(),
        isShowTextarea: false,
        userType: "",
        alarmTime: "",
        formData: {
          jointDefenseCaptainFullname: "", //联防队长
          jointDefenseCaptain: "",
          alarmTime: new Date().getTime(),
          alarmLocation: "",
          remark: "",
          inspectUserFullname: "", //审批人
          dealUserFullname: "", //执行人
          dealUserName: "",
          inspectUser: "",
          notifyMethod: JSON.stringify(["0"]),
          alarmType: "2",
          executorFeedbackResult: "", //执行人反馈结果
          executorFeedbackPicture: "", //  执行人反馈图片
          executorFeedbackTime: "", //  执行人反馈时间
          approvalComments: "", // 审批意见
          approvalTime: "", //  审批时间
          lastApproverName: "",
          lastApproverFullname: "",
          equipmentNumber: "",
          approverName1: "",
          approverFullname1: "",
          vehicleNumber: "",
          picture: "",
          alarmPersonName: "",
          alarmPersonFullName: "",
          reserveUser: "",
          vehicleName: "",
          alertorType: "",
          targetType: "",
        },
        rules: {
          alarmPersonFullName: [
            {
              required: true,
              message: "请选择报警人",
              trigger: ["change"],
            },
          ],
          eventName: [
            {
              required: true,
              message: "请输入事件名称",
              trigger: ["change"],
            },
          ],
          eventReportUserPhone: [
            {
              validator: (rule, value, callback) => {
                return uni.$u.test.mobile(value);
              },
              message: "上报人手机号码不正确",
              trigger: ["change"],
            },
          ],
          alarmLocation: [
            {
              required: true,
              message: "请选择报警位置",
              trigger: ["change"],
            },
          ],
          jointDefenseCaptainFullname: [
            {
              required: true,
              message: "请选择联防队长",
              trigger: ["change"],
            },
          ],
          vehicleNumber: [
            {
              require: true,
              message: "请输入车牌号",
              trigger: ["change"],
            },
            {
              require: true,
              validator: (role, val, cb) => {
                return this.$u.test.carNo(val);
              },
              message: "请输入正确的车牌号",
              trigger: ["blur"],
            },
          ],
          vehicleName: [
            {
              required: true,
              message: "请输入叉车车牌号",
              trigger: ["change"],
            },
          ],
        },
        taskList: ["UserTask_2", "UserTask_3"],
        showExecutorInfo: false, //流程全部走完时显示 走到审核人时也要显示 处理人处理完成
        showAuditorInfo: false, //流程全部走完时显示 审核人已经审批
        uploadImage: false,
        hasImage: false,
        userRole: "",
        showOtherMsg: false,
        formBizId: this.bizId,
        processState: "",
        imageList: [],
        showCloth: false,
      };
    },
    mounted () {
    },
  };
  </script>
  <style lang="scss" scoped>
  @import "./style.scss";
  </style>