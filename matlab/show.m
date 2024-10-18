import numpy as np
import matplotlib.pyplot as plt
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from PySide2.QtWidgets import QApplication, QMainWindow, QVBoxLayout, QWidget, QComboBox, QLabel, QGridLayout
from PySide2.QtCore import Qt

class Storage:
    def __init__(self):
        self.image_1 = np.random.rand(100, 100) * 255
        self.image_2 = np.random.rand(100, 100) * 255
        self.centers_map = None
        self.vectors_map = np.random.rand(100, 100, 2) * 10

def visual_vectors(Storage, ax, scale, width, colors):
    # Placeholder for the visual_vectors function
    # This function should return the graphics objects for the vectors
    dv = ax.quiver(Storage.centers_map[0], Storage.centers_map[1], Storage.vectors_map[..., 0], Storage.vectors_map[..., 1], color=colors[0])
    do = di = dr2 = dr3 = ovm = ivm = r2vm = r3vm = None
    return dv, do, di, dr2, dr3, ovm, ivm, r2vm, r3vm

class Visualizer(QMainWindow):
    def __init__(self, Storage):
        super().__init__()
        self.Storage = Storage
        self.initUI()

    def initUI(self):
        self.setWindowTitle('Visualizer')
        self.setGeometry(200, 100, 1000, 600)

        # Create main widget and layout
        main_widget = QWidget(self)
        self.setCentralWidget(main_widget)
        main_layout = QGridLayout(main_widget)

        # Create configuration panel
        config_panel = QWidget(self)
        config_layout = QGridLayout(config_panel)
        main_layout.addWidget(config_panel, 0, 0)

        # Create plot area
        plot_widget = QWidget(self)
        plot_layout = QVBoxLayout(plot_widget)
        main_layout.addWidget(plot_widget, 0, 1)

        # Create figure and axis for the plot
        self.fig, self.ax = plt.subplots()
        self.canvas = FigureCanvas(self.fig)
        plot_layout.addWidget(self.canvas)

        # Number of graphics contained in the parent
        self.list_Graphics = 0

        # Background
        background = self.ax.imshow((self.Storage.image_1 + self.Storage.image_2) / 2, vmin=0, vmax=255)
        self.list_Graphics += 1

        # If the centers of the interrogation windows are not calculated, we assume each pixel of the image as the center
        if self.Storage.centers_map is None:
            self.Storage.centers_map = np.meshgrid(np.arange(self.Storage.image_1.shape[1]), np.arange(self.Storage.image_1.shape[0]))

        # Display the vector field with standard parameters
        self.dv, self.do, self.di, self.dr2, self.dr3, self.ovm, self.ivm, self.r2vm, self.r3vm = visual_vectors(self.Storage, self.ax, 1.0, 2.0, ['green', 'red', 'blue', 'magenta', 'cyan'])
        self.list_Graphics += 5

        # Calculate the line plot (not displayed at the beginning)
        self.ax.streamplot(self.Storage.centers_map[0], self.Storage.centers_map[1], self.Storage.vectors_map[..., 0], self.Storage.vectors_map[..., 1])
        for child in self.ax.get_children()[:-self.list_Graphics]:
            child.set_color('none')

        # Array of available colors
        colors = ['green', 'red', 'blue', 'magenta', 'cyan', 'yellow', 'black', 'white', 'none']

        # Dropdown list for normal vectors
        vectors_label = QLabel('Vectors', self)
        config_layout.addWidget(vectors_label, 0, 0, Qt.AlignLeft)
        self.vectors_combo = QComboBox(self)
        self.vectors_combo.addItems(colors)
        self.vectors_combo.currentIndexChanged.connect(self.update_vectors_color)
        config_layout.addWidget(self.vectors_combo, 0, 1)

    def update_vectors_color(self):
        color = self.vectors_combo.currentText()
        for line in self.dv:
            line.set_color(color)
        self.canvas.draw()

def show(Storage):
    app = QApplication([])
    visualizer = Visualizer(Storage)
    visualizer.show()
    app.exec_()

# Example usage
storage = Storage()
show(storage)