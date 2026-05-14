<template>
  <div class="container">
    <view class="title">
      苗圃详情</view>
    <view>
      <u--form labelPosition="left" :model="formData" :borderBottom="true">
        <u-form-item label="苗圃位置" prop="nurLocation" borderBottom>
          <div style="display: flex; width: 100%" @click="showAddressHandler">
            <u--text :text="formData.nurLocation || '请选择苗圃位置'" :color="formData.nurLocation ? '#000' : '#ccc'"
              align="right"></u--text>
            <u-icon slot="right" name="arrow-right" color="#ccc"></u-icon>
          </div>
        </u-form-item>
        <u-form-item label="手机号" prop="nurPhone" borderBottom>
          <u--input v-model="formData.nurPhone" placeholder="请输入" border="none" inputAlign="right" />
        </u-form-item>
        <view class="title">
          苗木详情</view>
        <u-form-item label="苗木名称" prop="nurName" borderBottom>
          <u--input v-model="formData.nurName" placeholder="请输入手机号" border="none" inputAlign="right" />
        </u-form-item>
        <u-form-item label="苗木价格" prop="nurPri" borderBottom>
          <u--input v-model="formData.nurPri" placeholder="请输入苗木价格" border="none" inputAlign="right" />
        </u-form-item>
        <u-form-item label="苗木直径" prop="nurSize" borderBottom>
          <u--input border="none" inputAlign="right" placeholder="请输入苗木直径" v-model="formData.nurSize"></u--input>
        </u-form-item>
        <u-form-item label="苗木图片" prop="vehicleName" borderBottom>
          <u-upload :fileList="picList" @afterRead="afterRead" @delete="deletePic" name="1" :maxCount="3"
            uploadIconColor="red" :previewFullImage="true"></u-upload>
        </u-form-item>
      </u--form>
    </view>
    <div style="margin-top: 80rpx">
      <u-button text="提交" type="primary" @click="submit"></u-button>
    </div>
    <div style="margin-top: 40rpx">
      <u-button text="重置" type="error" @click="clear"></u-button>
    </div>

  </div>
</template>

<script>
import { getFlowInstance } from "@/api/bpm";
import jadeImageUpload from "@/components/jade-image-upload/jade-image-upload.vue";
import uploadImage from "@/components/uploadImage";
export default {
  components: { jadeImageUpload, uploadImage },
  data() {
    return {
      minDate: Date.now(),
      formData: {
        nurLocation: '',
        nurPhone: '',
        nurSize: '',
        nurName: '',
        nurPic: '',
        nurPri: ''
      },
      rules: {
        nurName: [
          {
            required: true,
            message: "请填写苗木名称",
            trigger: ["change"],
          },
        ],
        nurPhone: [
          {
            validator: (rule, value, callback) => {
              return uni.$u.test.mobile(value);
            },
            message: "手机号码不正确",
            trigger: ["change"],
          },
        ],
        nurLocation: [
          {
            required: true,
            message: "请选择苗圃位置",
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
      picList: [],
      messageId: '',
    };
  },
  methods: {
    getRandom(num) {
      this.messageId = Math.floor((Math.random()+Math.floor(Math.random()*9+1))*Math.pow(10,num-1))+ '';
    },
    showAddressHandler() {
      uni.chooseLocation({
        success: (res) => {
          /**这个res中应该有许多的内容 还需要将经纬度信息存储到数据库中 */
          this.formData.nurLocation = res.address;
        },
      });
    },
    clear() {
      for (let key in this.formData) {
        this.formData[key] = '';
      }
    },
    submit(data) {
      this.formData.messageId = this.messageId;
      this.$request('/stored/info', 'POST', this.formData).then((res) => {
      })
    },
    async afterRead(event) {
      let lists = [].concat(event.file)
      let fileListLen = this.picList.length
      lists.map((item) => {
        this.picList.push({
          ...item,
          status: 'uploading',
          message: '上传中'
        })
      })
      for (let i = 0; i < lists.length; i++) {
        const result = await this.uploadFilePromise(lists[i].url, this.messageId)
        let item = this.picList[fileListLen]
        this.picList.splice(fileListLen, 1, Object.assign(item, {
          status: 'success',
          message: '',
          url: result.data
        }))
        fileListLen++
      }
    },
    uploadFilePromise(url, messageId) {
      return new Promise((resolve, reject) => {
        uni.uploadFile({
          url: 'http://10.218.72.73:8081/upload/image',
          filePath: url,
          name: 'file',
          header: { 'content-type': 'multipart/form-data' },
          formData: {
            user: 'test',
            messageId: messageId
          },
          success: (res) => {
            setTimeout(() => {
              resolve( JSON.parse( res.data ) )
            }, 1000)
          },
          fail: (res) => {
          }
        });
      })
    },
    deletePic(event) {
      this.picList.splice(event.index, 1)
    }
  },
  onLoad(){
    this.getRandom( 10 )
  },
  mounted() {
  },
};
</script>
<style>
::v-deep .u-upload__button {
  background-color: rgb(218, 213, 213) !important;
}
</style>
<style lang="scss" scoped>
@import "./style.scss";
</style>