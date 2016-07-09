using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Win10_IOT_Console.Model
{
    public enum DoorState { Open = 1, Closed = 0, Unknown = -1 }

    public class Dashboard : INotifyPropertyChanged
    {
        protected DoorState garageDoor = DoorState.Unknown;

        public event PropertyChangedEventHandler PropertyChanged;

        public DoorState GarageDoor
        {
            get { return garageDoor; }
            set { this.garageDoor = value; NotifyChanged("GarageDoor"); }
        }

        protected void NotifyChanged(string name)
        {
            if( PropertyChanged != null )
            {
                PropertyChanged(this, new PropertyChangedEventArgs(name));
            }
        }
    }
}
