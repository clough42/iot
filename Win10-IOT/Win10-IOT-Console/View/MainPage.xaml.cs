using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.WindowsRuntime;
using System.Text;
using uPLibrary.Networking.M2Mqtt;
using uPLibrary.Networking.M2Mqtt.Messages;
using Win10_IOT_Console.Model;
using Windows.Data.Json;
using Windows.Foundation;
using Windows.Foundation.Collections;
using Windows.UI.Core;
using Windows.UI.Xaml;
using Windows.UI.Xaml.Controls;
using Windows.UI.Xaml.Controls.Primitives;
using Windows.UI.Xaml.Data;
using Windows.UI.Xaml.Input;
using Windows.UI.Xaml.Media;
using Windows.UI.Xaml.Navigation;

// The Blank Page item template is documented at http://go.microsoft.com/fwlink/?LinkId=402352&clcid=0x409

namespace Win10_IOT_Console
{
    /// <summary>
    /// An empty page that can be used on its own or navigated to within a Frame.
    /// </summary>
    public sealed partial class MainPage : Page
    {
        protected const string BROKERHOST = "10.98.76.246";

        public MainPage()
        {
            this.ViewModel = new Dashboard();
            this.InitializeComponent();

            MqttClient mqtt = new MqttClient(BROKERHOST);
            mqtt.MqttMsgPublishReceived += Mqtt_MqttMsgPublishReceived;
            string clientId = Guid.NewGuid().ToString();
            mqtt.Connect(clientId);

            mqtt.Subscribe(new string[] { "sensor/10488302/value" }, new byte[] { MqttMsgBase.QOS_LEVEL_AT_LEAST_ONCE });
        }

        private async void Mqtt_MqttMsgPublishReceived(object sender, uPLibrary.Networking.M2Mqtt.Messages.MqttMsgPublishEventArgs e)
        {
            switch( e.Topic )
            {
                case "sensor/10488302/value":
                    string message = Encoding.ASCII.GetString(e.Message);
                    JsonObject json = JsonObject.Parse(message);
                    int doorValue = (int)json.GetNamedNumber("value");
                    DoorState newDoorState = (DoorState)doorValue;

                    await Windows.ApplicationModel.Core.CoreApplication.MainView.CoreWindow.Dispatcher.RunAsync(
                        CoreDispatcherPriority.Normal,
                        () => { ViewModel.GarageDoor = newDoorState; }
                    );

                    break;
            }
        }

        public Dashboard ViewModel { get; set; }
    }
}
