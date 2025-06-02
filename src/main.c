#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>  
#include <stdint.h>

#define STB_IMAGE_IMPLEMENTATION
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image.h"
#include "stb_image_write.h"

void show_menu();
void apply_filter(unsigned char* gray_img, int width, int height, const char* output_path, int filter_type);
void apply_laplacian(unsigned char* gray_img, unsigned char* output, int width, int height);
void apply_prewitt(unsigned char* gray_img, unsigned char* output, int width, int height);
void apply_sobel_3x3(unsigned char* gray_img, unsigned char* output, int width, int height);
void apply_sobel_5x5(unsigned char* gray_img, unsigned char* output, int width, int height); 
unsigned char* convert_to_grayscale(const char* input_path, int* width, int* height);



void driver(const int8_t* kernel, const int8_t* region, int8_t* result, int size, int opcode);

// extern void mmap_setup();
// extern void driver(int8_t *matrixA, int8_t *matrixB, int8_t *matrixR, int size, int op_opcode);
// extern void mmap_cleanup();

int main() {
    // mmap_setup();

    int start = 1;
    while (start) {
        int op = 0;
        printf("1 - Programa\n0 - Sair\n\nEscolha uma opcao: ");
        if (scanf("%d", &op) != 1) {
            while (getchar() != '\n');
            printf("Entrada invalida. Por favor, insira um numero.\n");
            continue;
        }

        if (op == 0) {
            printf("Saindo...\n");
            start = 0;
            break;
        }
        
        if (op != 1) {
            printf("Opcao invalida. Tente novamente.\n");
            continue;
        }

        int width, height;
        char input_path[100];
        printf("\nDigite o nome da imagem (ex: imagem.jpg): ");
        if (scanf("%99s", input_path) != 1) {
             while (getchar() != '\n');
             printf("Erro ao ler o nome da imagem.\n");
             continue;
        }

        char full_path[200];
        snprintf(full_path, sizeof(full_path), "../images/data/%s", input_path);

        unsigned char* gray_img = convert_to_grayscale(full_path, &width, &height);
        if (!gray_img) {
            continue;
        }

        int choice = 10;
        while (choice != 0) {
            show_menu();
            printf("\nEscolha uma opcao: ");
            if (scanf("%d", &choice) != 1) {
                while (getchar() != '\n');
                printf("Entrada invalida. Por favor, insira um numero.\n");
                continue;
            }
            
            char ouput_path[200];

            switch (choice) {
                case 1:
                    snprintf(ouput_path, sizeof(ouput_path), "../images/output/laplacian_%s", input_path);

                    apply_filter(gray_img, width, height, ouput_path, 1);
                    printf("Filtro Laplaciano aplicado e salvo como laplacian_name.png\n");
                    break;
                case 2:
                    snprintf(ouput_path, sizeof(ouput_path), "../images/output/prewitt_%s", input_path);

                    apply_filter(gray_img, width, height, ouput_path, 2);
                    printf("Filtro Prewitt (5x5) aplicado e salvo como prewitt_name.png\n");
                    break;
                case 3:
                    snprintf(ouput_path, sizeof(ouput_path), "../images/output/sobel3x3_%s", input_path);

                    apply_filter(gray_img, width, height, ouput_path, 3);
                    printf("Filtro Prewitt (5x5) aplicado e salvo como sobel3x3_name.png\n");
                    break;
                case 4:
                    snprintf(ouput_path, sizeof(ouput_path), "../images/output/sobel5x5_%s", input_path);

                    apply_filter(gray_img, width, height, ouput_path, 4);
                    printf("Filtro Prewitt (5x5) aplicado e salvo como sobel5x5_name.png\n");
                    break;
                case 0:
                    printf("Retornando ao menu principal...\n\n");
                    break;
                default:
                    printf("Opcao invalida! Tente novamente.\n");
            }
        }
        stbi_image_free(gray_img);
    }
    
    // mmap_cleanup();
    return 0;
}

void show_menu() {
    printf("\n=== MENU DE FILTROS ===\n");
    printf("1 - Aplicar Filtro Laplaciano (5x5)\n");
    printf("2 - Aplicar Filtro Prewitt (5x5)\n");
    printf("3 - Aplicar Filtro Sobel (3x3)\n");
    printf("4 - Aplicar Filtro Sobel (5x5)\n");
    printf("0 - Voltar ao menu principal\n");
}

void driver(const int8_t* kernel, const int8_t* region, int8_t* result, int size, int opcode) {
        if(size == 1){
            int sum = 0;
            for (int i = 0; i < 3; i++) {
                for (int e = 0; e < 3; e++) {
                    sum += kernel[i * 3 + e] * region[i * 3 + e];
                }
            }
        
            if (sum >= 127) {
                result[0] = 127;
            } else if (sum <= 0) {
                result[0] = 0;
            } else {
                result[0] = (int8_t)sum;
            }
        }

        if(size == 3){
            int sum = 0;
            for (int i = 0; i < 5; i++) {
                for (int e = 0; e < 5; e++) {
                    sum += kernel[i * 5 + e] * region[i * 5 + e];
                }
            }
        
            if (sum >= 127) {
                result[0] = 127;
            } else if (sum <= 0) {
                result[0] = 0;
            } else {
                result[0] = (int8_t)sum;
            }
        }
}

void apply_filter(unsigned char* gray_img, int width, int height, const char* output_path, int filter_type) {
    unsigned char* output = (unsigned char*)malloc(width * height * sizeof(unsigned char));
    
    if (!output) {
        printf("Erro: Falha ao alocar memoria para a imagem de saida!\n");
        return;
    }

    memcpy(output, gray_img, width * height * sizeof(unsigned char));

    if (filter_type == 1) {
        apply_laplacian(gray_img, output, width, height);
    } else if (filter_type == 2) {
        apply_prewitt(gray_img, output, width, height);
    } else if (filter_type == 3) {
        apply_sobel_3x3(gray_img, output, width, height);
    } else if (filter_type == 4) {
        apply_sobel_5x5(gray_img, output, width, height);
    }else{
        
    }

    if (!stbi_write_jpg(output_path, width, height, 1, output, 90)) {
        printf("Erro ao salvar a imagem filtrada em %s!\n", output_path);
    }
    free(output);
}

void apply_laplacian(unsigned char* gray_img, unsigned char* output, int width, int height) {
    // Kernel Laplaciano
    int8_t laplacian_kernel[] = {
        0, 0,  1, 0, 0,
        0, 1,  2, 1, 0,
        1, 2,-16, 2, 1,
        0, 1,  2, 1, 0,
        0, 0,  1, 0, 0
    };
    
    // Tamanho do kernel (5x5)
    int kernel_size = 5;

    // Metade do tamanho do kernel (para evitar processar bordas)
    int half_kernel = kernel_size / 2; 

    // Percorre cada pixel da imagem (exceto bordas)
    for (int y = half_kernel; y < height - half_kernel; y++) {
        for (int x = half_kernel; x < width - half_kernel; x++) {

            // Extrai uma região 5x5 ao redor do pixel (y, x)
            int8_t region_s8[25];
            
            int idx = 0;
            for (int ky = -half_kernel; ky <= half_kernel; ky++) {
                for (int kx = -half_kernel; kx <= half_kernel; kx++) {
                    // Os pixels são convertidos para int8_t (-128 a 127) subtraindo 128
                    region_s8[idx++] = (int8_t)(gray_img[(y + ky) * width + (x + kx)] - 128);
                }
            }
            
            // Armazena o resultado da convolução
            int8_t convolution_result_s8_array[25];

            // Aplica a convolução usando o kernel Laplaciano
            driver(laplacian_kernel, region_s8, convolution_result_s8_array, 3, 2);
            
            // Armazena o resultado no pixel de saída (convertendo para 0-255)
            output[y * width + x] = (unsigned char)convolution_result_s8_array[0];
        }
    }
}

void apply_prewitt(unsigned char* gray_img, unsigned char* output, int width, int height) {
    // Kernels de Prewitt para detecção de bordas em X e Y
    int8_t prewitt_x_kernel[] = {
        -1,  0,  1,  
        -1,  0,  1,
        -1,  0,  1
    };

    int8_t prewitt_y_kernel[] = {
        -1, -1, -1,
         0,  0,  0,  
         1,  1,  1
    };
    
    // Tamanho do kernel (3x3)
    int kernel_size = 3;

    // Metade do tamanho do kernel (para evitar processar bordas)
    int half_kernel = kernel_size / 2;

    // Percorre cada pixel da imagem (exceto bordas)
    for (int y = half_kernel; y < height - half_kernel; y++) {
        int count = 0;
        
        for (int x = half_kernel; x < width - half_kernel; x++) {
            // Extrai uma região 3x3 ao redor do pixel (y, x)
            int8_t region_s8[9];
            int idx = 0;

            for (int ky = -half_kernel; ky <= half_kernel; ky++) {
                for (int kx = -half_kernel; kx <= half_kernel; kx++) {
                    // Converte pixels para int8_t (-128 a 127) subtraindo 128
                    region_s8[idx++] = (int8_t)(gray_img[(y + ky) * width + (x + kx)] - 128);
                }
            }
            
            // Resultados das convoluções em X e Y
            int8_t gx_result[9], gy_result[9];
            
            // Aplica convolução nas direções X e Y
            driver(prewitt_x_kernel, region_s8, gx_result, 1, 2);
            driver(prewitt_y_kernel, region_s8, gy_result, 1, 2);

            printf("\ncount %d\nsum x: %hhd\nsum y: %hhd", count, gx_result[0], gy_result[0]);
            count += 1;
            
            // Calcula a magnitude do gradiente (aproximação)
            int16_t gx = gx_result[0];
            int16_t gy = gy_result[0];
            int16_t magnitude = abs(gx) + abs(gy);
            
            // Armazena o resultado (0-255)
            output[y * width + x] = (unsigned char)(magnitude);   
        }
    }
}

void apply_sobel_3x3(unsigned char* gray_img, unsigned char* output, int width, int height) {
    int8_t sobel_x_kernel_3x3[] = {
        -1, 0, 1,
        -2, 0, 2,
        -1, 0, 1
    };
    int8_t sobel_y_kernel_3x3[] = {
        -1, -2, -1,
         0, 0, 0,
         1, 2, 1
    };

    int size = 3;
    int border = size / 2;

    for (int y = border; y < height - border; y++) {
        for (int x = border; x < width - border; x++) {
            int region[9]; // 3x3
            int idx = 0;
            for (int ky = -border; ky <= border; ky++) {
                for (int kx = -border; kx <= border; kx++) {
                    region[idx++] = gray_img[(y + ky) * width + (x + kx)];
                }
            }

            int8_t result_x = 0, result_y = 0;
            // Assuming the driver function handles the convolution
            // and the opcode '1' signifies this type of operation.
            driver(sobel_x_kernel_3x3, region, &result_x, size, 1);
            driver(sobel_y_kernel_3x3, region, &result_y, size, 1);

            // Calculate gradient magnitude
            // G = sqrt(Gx^2 + Gy^2)
            // The C driver clamps Gx and Gy results to [0,255].
            int8_t magnitude = (int)sqrt((double)result_x * result_x + (double)result_y * result_y);

            // Clamp the magnitude to [0, 255] and assign to output
            output[y * width + x] = (unsigned char)(magnitude > 255 ? 255 : (magnitude < 0 ? 0 : magnitude));  
        }
    }
}

void apply_sobel_5x5(unsigned char* gray_img, unsigned char* output, int width, int height) {
   // Using Scharr 5x5 kernels as a common, optimized Sobel-like operator for 5x5
   int8_t sobel_x_kernel_5x5[] = {
    1, 2, 0, -2, -1,
    4, 8, 0, -8, -4,
    6, 12, 0, -12, -6,
    4, 8, 0, -8, -4,
    1, 2, 0, -2, -1
    };

    int8_t sobel_y_kernel_5x5[] = {
    1, 4, 6, 4, 1,
    2, 8, 12, 8, 2,
    0, 0, 0, 0, 0,
    -2, -8,-12, -8, -2,
    -1, -4, -6, -4, -1
    };

    int size = 5; // Kernel size
    int border = size / 2; // 2 for 5x5

    for (int y = border; y < height - border; y++) {
    for (int x = border; x < width - border; x++) {
        int region[25]; // 5x5 = 25 elements
        int idx = 0;
        for (int ky = -border; ky <= border; ky++) {
            for (int kx = -border; kx <= border; kx++) {
                region[idx++] = gray_img[(y + ky) * width + (x + kx)];
            }
        }

        int8_t result_x = 0, result_y = 0;
        driver(sobel_x_kernel_5x5, region, &result_x, size, 1);
        driver(sobel_y_kernel_5x5, region, &result_y, size, 1);

        // Calculate gradient magnitude: G = sqrt(Gx^2 + Gy^2)
        // The C driver clamps Gx and Gy results to [0,255].
        int8_t magnitude = (int)sqrt((double)result_x * result_x + (double)result_y * result_y);

        // Clamp the magnitude to [0, 255] and assign to output
        output[y * width + x] = (unsigned char)(magnitude > 255 ? 255 : (magnitude < 0 ? 0 : magnitude));
        }
    }
}

unsigned char* convert_to_grayscale(const char* input_path, int* width, int* height) {
    int channels;
    unsigned char* img = stbi_load(input_path, width, height, &channels, 1);

    if (!img) {
        printf("Erro ao carregar a imagem de %s! Verifique o caminho e o formato do arquivo.\n", input_path);
        printf("STB Image Error: %s\n", stbi_failure_reason());
        return NULL;
    }

    printf("Imagem %s carregada: %dpx x %dpx, Canais Originais: %d, Convertida para Escala de Cinza\n", input_path, *width, *height, channels);
    return img;
}
