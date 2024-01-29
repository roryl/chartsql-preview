/**
 * PresentationMode Pen Drawing
 * Adapted from Canvas Drawing:
 * https://codepen.io/zsolt555/pen/rpPXOB
 *
 * Implements drawing on the chart while in presentation mode. The user
 * pressing ctrl will allow them to draw on the chart. The drawing is saved
 * to local storage and restored when the user returns to the chart (or any other chart)
 */
class PresentationMode {

    constructor() {
        this.paintCanvas = document.querySelector('.js-paint');
        this.context = this.paintCanvas.getContext('2d');
    }

	init() {
        this.restoreCanvas();
        this.setupCanvasSize();
        this.setupDrawingTools();
        this.setupDrawingEvents();
        this.enablePointerEventsOnCtrl();
        this.clearCanvasOnEsc();
        return this;
    }

    saveCanvas() {
        localStorage.setItem('canvas', this.paintCanvas.toDataURL());
    }

    restoreCanvas() {
        const dataURL = localStorage.getItem('canvas');
        if (dataURL) {
            const img = new Image();
            img.onload = () => {
                this.context.clearRect(0, 0, this.paintCanvas.width, this.paintCanvas.height);
                this.context.drawImage(img, 0, 0);
            };
            img.src = dataURL;
        }
    }

    setupDrawingTools() {
        const colorPicker = document.querySelector('.js-color-picker');
        this.context.strokeStyle = colorPicker.value;
        colorPicker.addEventListener('change', event => {
            this.context.strokeStyle = event.target.value;
        });

        const lineWidthRange = document.querySelector('.js-line-range');
        this.context.lineWidth = lineWidthRange.value;
        const lineWidthLabel = document.querySelector('.js-range-value');

        lineWidthRange.addEventListener('input', event => {
            const width = event.target.value;
            lineWidthLabel.textContent = width;
            this.context.lineWidth = width;
        });
    }

    setupCanvasSize() {
        this.paintCanvas.width = this.paintCanvas.parentNode.clientWidth * 0.98;
        this.paintCanvas.height = this.paintCanvas.parentNode.clientHeight * 0.98;
        this.context.lineCap = 'round';
    }

    setupDrawingEvents() {
        let isMouseDown = false;
        let lastX = 0;
        let lastY = 0;

        const startDrawing = event => {
            isMouseDown = true;
            [lastX, lastY] = [event.offsetX, event.offsetY];
        };

        const drawLine = event => {
            if (isMouseDown) {
                const newX = event.offsetX;
                const newY = event.offsetY;
                this.context.beginPath();
                this.context.moveTo(lastX, lastY);
                this.context.lineTo(newX, newY);
                this.context.stroke();
                [lastX, lastY] = [newX, newY];
            }
        };

        const stopDrawing = () => {
            if (isMouseDown) {
                isMouseDown = false;
                this.saveCanvas();
            }
        };

        this.paintCanvas.addEventListener('mousedown', startDrawing);
        this.paintCanvas.addEventListener('mousemove', drawLine);
        this.paintCanvas.addEventListener('mouseup', stopDrawing);
        this.paintCanvas.addEventListener('mouseout', stopDrawing);
    }

    enablePointerEventsOnCtrl() {

		//2024-01-10: Added Meta to support MacOS command key
        document.addEventListener('keydown', event => {
            if (event.key === 'Control' || event.key === 'Meta') {
                this.paintCanvas.style.pointerEvents = 'auto';
            }
        });

        document.addEventListener('keyup', event => {
            if (event.key === 'Control' || event.key === 'Meta') {
                this.paintCanvas.style.pointerEvents = 'none';
            }
        });
    }

    clearCanvasOnEsc() {
        document.addEventListener('keyup', event => {
            if (event.key === 'Escape') {
                this.context.clearRect(0, 0, this.paintCanvas.width, this.paintCanvas.height);
                localStorage.removeItem('canvas');
            }
        });
    }

}
